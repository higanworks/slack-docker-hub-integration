Docker Hub build notifications for Slack
========================================

A tiny Sinatra app that receives webhooks from Docker Hub and re-posts them as formatted hooks.

## Here's how to get setup...

1. Generate an incoming webhook in the Slack integration settings e.g. `https://hooks.slack.com/services/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`
2. Switch the domain from `hooks.slack.com` to `slack-from-docker-hub.yourdomain.com`
3. Create a new webhook on Docker Hub with pointing to this url. e.g. `https://slack-from-docker-hub.yourdomain.com/services/T024XLT1F/B031BS1D0/C4YkI21H6jPQ59PHLQLD3S21`


Alternatively you could host the code yourself.


Experimental support Typetalk.

- create bot which is allowed `topic.post` and pick up TypeTalk Token.

set webhook like below.

```
https://slack-from-docker-hub.yourdomain.com/typetalkv1/${roomNumber}/${TypeTalkToken}
```

----

test localy.

```
$ docker run -it --rm -p 8080:8080 slack-docker-hub-integration:latest
```

run on [now](https://zeit.co).

```
$ now higanworks/slack-docker-hub-integration#master
```
