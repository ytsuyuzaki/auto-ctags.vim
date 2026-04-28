FROM ruby:3.2

RUN apt-get update && apt-get install -y --no-install-recommends \
	vim-gtk3 \
	exuberant-ctags \
	xvfb \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir /vim-test
WORKDIR /vim-test

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
