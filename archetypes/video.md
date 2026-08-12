+++
date = '{{ .Date }}'
draft = false
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
type = 'video'

# Short pitch for list cards and the lead on the page (Markdown ok).
description = ''

# From the watch URL: …youtube.com/watch?v=THIS_PART
youtube_id = ''

subtitle = ''

# Taxonomy hubs (Mind-Infrastructure, Human-Condition, Social-Protocols, etc.); pick folder under content/ by main job (see .cursor/rules/content-placement.mdc).
categories = ['Mind-Infrastructure']

tags = []
+++

TLDR / so-what article below the embed (summary for readers who skip the watch). Alternatively, leave `youtube_id` empty and add the built-in YouTube shortcode in Markdown.
