FROM ruby:2.7.0-buster

ENV LANG=C.UTF-8 \
    TZ=Asia/Seoul \
    APP_HOME=/app \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

WORKDIR $APP_HOME

# System packages
RUN printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive \
    && printf '%s\n' \
      'deb http://archive.debian.org/debian buster main' \
      'deb http://archive.debian.org/debian-security buster/updates main' \
      > /etc/apt/sources.list \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
    gnupg \
    xz-utils \
    pkg-config \
    libpq-dev \
    postgresql-client \
    imagemagick \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

# Node.js + Yarn
# Node 14는 NodeSource apt repo보다 공식 archive tarball로 고정 설치
ARG NODE_VERSION=14.21.3
RUN curl -fsSLO https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz \
    && tar -xJf node-v${NODE_VERSION}-linux-x64.tar.xz -C /usr/local --strip-components=1 \
    && rm node-v${NODE_VERSION}-linux-x64.tar.xz \
    && npm install -g yarn@1.22.22

# Bundler version for Ruby 2.7 / Rails 6 legacy apps
RUN gem install bundler -v 2.4.22

# Gem install layer
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' \
    && bundle install

# Yarn install layer
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# App source
COPY . .

# Rails production defaults
ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

EXPOSE 3000

# Puma config/puma.rb 가 있다고 가정
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
