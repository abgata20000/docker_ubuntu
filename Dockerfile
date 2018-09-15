FROM ubuntu:16.04
MAINTAINER abgata@abgata.jp

ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8" \
    RUBY_VER="2.5.1" \
    RAILS_VER="5.1.4"

RUN apt-get update

# 日本語設定
RUN apt-get -y install language-pack-ja-base language-pack-ja ibus-mozc
RUN localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

# タイムゾーン設定
RUN timedatectl set-timezone Asia/Tokyo

# 必要なパッケージをインストール
RUN apt-get -y install vim which git make autoconf curl wget gcc-c++ glibc-headers openssl-devel readline libyaml-devel readline-devel zlib zlib-devel sqlite-devel bzip2 libreadline-dev build-essential libssl-dev

# rubyとbundleをダウンロード
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv \
    && git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

# コマンドでrbenvが使えるように設定
RUN echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh \
    && echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh \
    && echo 'eval "$(rbenv init --no-rehash -)"' >> /etc/profile.d/rbenv.sh

ENV RBENV_ROOT="/usr/local/rbenv" \
    GEM_HOME="/usr/local/bundle"
ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH="$BUNDLE_BIN:$RBENV_ROOT:/bin:/usr/local/rbenv/versions/${RUBY_VER}/bin:$PATH"
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
    && chmod 775 "$GEM_HOME" "$BUNDLE_BIN"

# rubyとrailsをインストール
RUN source /etc/profile.d/rbenv.sh; MAKE_OPTS="-j 4" RUBY_BUILD_CURL_OPTS=--tlsv1.2 rbenv install ${RUBY_VER}; rbenv global ${RUBY_VER}; ruby -v; gem -v;
RUN source /etc/profile.d/rbenv.sh; gem update --system; gem install --version ${RAILS_VER} --no-ri --no-rdoc rails; gem install bundle; bundle -v;
