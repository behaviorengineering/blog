package facebookautopost

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const (
	graphAPIVersion        = "v20.0"
	maxGraphResponseBytes  = 1 << 20 // 1 MiB cap on Graph API JSON/error bodies
)

func readGraphResponse(r io.Reader) ([]byte, error) {
	limited := io.LimitReader(r, maxGraphResponseBytes+1)
	body, err := io.ReadAll(limited)
	if err != nil {
		return nil, err
	}
	if len(body) > maxGraphResponseBytes {
		return nil, fmt.Errorf("response body exceeds %d bytes", maxGraphResponseBytes)
	}
	return body, nil
}

// Client calls the Facebook Graph API with a bounded HTTP timeout.
type Client struct {
	HTTP       *http.Client
	BaseURL    string
	RetrySleep func(time.Duration) // nil uses time.Sleep; tests may set a no-op
}

// NewClient returns an HTTP client configured with the given timeout (minimum 1s).
func NewClient(timeout time.Duration) *Client {
	if timeout < time.Second {
		timeout = time.Second
	}
	return &Client{
		HTTP:    &http.Client{Timeout: timeout},
		BaseURL: "https://graph.facebook.com/" + graphAPIVersion,
	}
}

func (c *Client) graphURL(path string) string {
	path = strings.TrimLeft(path, "/")
	return c.BaseURL + "/" + path
}

func (c *Client) postForm(endpoint string, form url.Values) error {
	req, err := http.NewRequest(http.MethodPost, endpoint, strings.NewReader(form.Encode()))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	resp, err := c.HTTP.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	body, err := readGraphResponse(resp.Body)
	if err != nil {
		return fmt.Errorf("facebook %s: read response body: %w", endpoint, err)
	}
	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return newGraphHTTPError(endpoint, resp.StatusCode, string(body))
	}
	return nil
}

type pagePost struct {
	Message string `json:"message"`
	Story   string `json:"story"`
}

type pageFeedResponse struct {
	Data []pagePost `json:"data"`
}

// RecentlyPostedURL reports whether any of the most recent Page feed items already contains urlStr
// in the message or story text.
func (c *Client) RecentlyPostedURL(pageID, accessToken, urlStr string, limit int) (bool, error) {
	if strings.TrimSpace(urlStr) == "" {
		return false, fmt.Errorf("url is empty")
	}
	if limit <= 0 {
		limit = 10
	}
	if limit > 100 {
		limit = 100
	}

	endpoint := c.graphURL(pageID + "/feed")
	u, err := url.Parse(endpoint)
	if err != nil {
		return false, err
	}
	q := u.Query()
	// message: link posts and many photo captions. story: fallback text on some photo/story items.
	// Avoid attachment aggregates; they can trigger version-gated deprecation errors.
	q.Set("fields", "message,story")
	q.Set("limit", fmt.Sprintf("%d", limit))
	q.Set("access_token", accessToken)
	u.RawQuery = q.Encode()

	req, err := http.NewRequest(http.MethodGet, u.String(), nil)
	if err != nil {
		return false, err
	}
	resp, err := c.HTTP.Do(req)
	if err != nil {
		return false, err
	}
	defer resp.Body.Close()
	body, err := readGraphResponse(resp.Body)
	if err != nil {
		return false, fmt.Errorf("facebook %s: read response body: %w", endpoint, err)
	}
	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return false, newGraphHTTPError(endpoint, resp.StatusCode, string(body))
	}

	var r pageFeedResponse
	if err := json.Unmarshal(body, &r); err != nil {
		return false, fmt.Errorf("facebook %s: json: %w", endpoint, err)
	}
	for _, p := range r.Data {
		if strings.Contains(p.Message, urlStr) || strings.Contains(p.Story, urlStr) {
			return true, nil
		}
	}
	return false, nil
}

// PostPhoto publishes a Page photo post (image URL + caption).
func (c *Client) PostPhoto(pageID, accessToken, imageURL, caption string) error {
	endpoint := c.graphURL(pageID + "/photos")
	form := url.Values{}
	form.Set("url", imageURL)
	form.Set("caption", caption)
	form.Set("published", "true")
	form.Set("access_token", accessToken)
	return c.postForm(endpoint, form)
}

// PostPhotoFromFile uploads a local image as multipart form field `source` and publishes it with caption.
// Graph expects multipart/form-data; access_token is sent in the query string (common for uploads).
func (c *Client) PostPhotoFromFile(pageID, accessToken, localPath, caption string) error {
	localPath = strings.TrimSpace(localPath)
	if localPath == "" {
		return fmt.Errorf("local image path is empty")
	}
	f, err := os.Open(localPath)
	if err != nil {
		return fmt.Errorf("open image: %w", err)
	}
	defer f.Close()

	st, err := f.Stat()
	if err != nil {
		return fmt.Errorf("stat image: %w", err)
	}
	if st.IsDir() {
		return fmt.Errorf("image path is a directory: %s", localPath)
	}

	endpoint := c.graphURL(pageID + "/photos")
	u, err := url.Parse(endpoint)
	if err != nil {
		return err
	}
	q := u.Query()
	q.Set("access_token", accessToken)
	u.RawQuery = q.Encode()

	var buf bytes.Buffer
	mp := multipart.NewWriter(&buf)
	if err := mp.WriteField("published", "true"); err != nil {
		return err
	}
	if err := mp.WriteField("caption", caption); err != nil {
		return err
	}
	part, err := mp.CreateFormFile("source", filepath.Base(localPath))
	if err != nil {
		return err
	}
	if _, err := io.Copy(part, f); err != nil {
		return err
	}
	if err := mp.Close(); err != nil {
		return err
	}

	req, err := http.NewRequest(http.MethodPost, u.String(), &buf)
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", mp.FormDataContentType())
	resp, err := c.HTTP.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	body, err := readGraphResponse(resp.Body)
	if err != nil {
		return fmt.Errorf("facebook %s: read response body: %w", endpoint, err)
	}
	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return newGraphHTTPError(endpoint, resp.StatusCode, string(body))
	}
	return nil
}

// PostLink publishes a feed post with message and link preview.
func (c *Client) PostLink(pageID, accessToken, message, link string) error {
	endpoint := c.graphURL(pageID + "/feed")
	form := url.Values{}
	form.Set("message", message)
	form.Set("link", link)
	form.Set("published", "true")
	form.Set("access_token", accessToken)
	return c.postForm(endpoint, form)
}
