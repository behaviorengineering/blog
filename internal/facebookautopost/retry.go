package facebookautopost

import (
	"log"
	"strings"
	"time"
)

const (
	DefaultPostRetries   = 3
	DefaultFeedScanLimit   = 25
)

type withRetryOpts struct {
	maxAttempts int
	logLabel    string
	beforeRetry func(attempt int, lastErr error) (done bool, doneErr error)
}

// PublishRequest configures a retried Page publish (photo or link).
type PublishRequest struct {
	PageID               string
	AccessToken          string
	PostURL              string
	FeedLimit            int
	MaxAttempts          int
	CheckFeedBeforeRetry bool
	Post                 func() error
}

// DoWithRetry calls fn up to maxAttempts times when Graph returns transient errors.
func (c *Client) DoWithRetry(maxAttempts int, fn func() error) error {
	return c.withRetry(withRetryOpts{
		maxAttempts: maxAttempts,
		logLabel:    "transient error",
	}, fn)
}

// RecentlyPostedURLWithRetry is RecentlyPostedURL with transient retries on the feed read.
func (c *Client) RecentlyPostedURLWithRetry(pageID, accessToken, urlStr string, limit, maxAttempts int) (bool, error) {
	var already bool
	err := c.withRetry(withRetryOpts{
		maxAttempts: maxAttempts,
		logLabel:    "transient error",
	}, func() error {
		var err error
		already, err = c.RecentlyPostedURL(pageID, accessToken, urlStr, limit)
		return err
	})
	return already, err
}

// PublishWithRetry posts up to MaxAttempts times. When CheckFeedBeforeRetry is true and PostURL is set,
// a transient publish error triggers a feed scan before the next attempt so a post that landed despite
// an error response does not get published twice.
func (c *Client) PublishWithRetry(req PublishRequest) error {
	maxAttempts := req.MaxAttempts
	if maxAttempts < 1 {
		maxAttempts = 1
	}
	feedLimit := req.FeedLimit
	if feedLimit <= 0 {
		feedLimit = DefaultFeedScanLimit
	}
	return c.withRetry(withRetryOpts{
		maxAttempts: maxAttempts,
		logLabel:    "transient publish error",
		beforeRetry: func(attempt int, last error) (bool, error) {
			if !req.CheckFeedBeforeRetry || strings.TrimSpace(req.PostURL) == "" {
				return false, nil
			}
			already, err := c.RecentlyPostedURLWithRetry(req.PageID, req.AccessToken, req.PostURL, feedLimit, maxAttempts)
			if err == nil && already {
				log.Printf("facebook: URL already on Page after transient publish error; treating as success: %s", req.PostURL)
				return true, nil
			}
			if err != nil {
				log.Printf("facebook: feed check before publish retry failed: %v; will retry publish", err)
			}
			return false, nil
		},
	}, req.Post)
}

func (c *Client) withRetry(opts withRetryOpts, fn func() error) error {
	maxAttempts := opts.maxAttempts
	if maxAttempts < 1 {
		maxAttempts = 1
	}
	sleep := c.RetrySleep
	if sleep == nil {
		sleep = time.Sleep
	}
	var last error
	for attempt := 1; attempt <= maxAttempts; attempt++ {
		last = fn()
		if last == nil {
			return nil
		}
		if attempt == maxAttempts || !IsTransientGraphError(last) {
			return last
		}
		if opts.beforeRetry != nil {
			done, doneErr := opts.beforeRetry(attempt, last)
			if done {
				return doneErr
			}
		}
		delay := retryDelayBeforeAttempt(attempt)
		log.Printf("facebook: %s attempt %d/%d: %v; retrying in %s", opts.logLabel, attempt, maxAttempts, last, delay)
		sleep(delay)
	}
	return last
}

func retryDelayBeforeAttempt(attempt int) time.Duration {
	switch attempt {
	case 1:
		return 5 * time.Second
	case 2:
		return 15 * time.Second
	default:
		return 15 * time.Second
	}
}
