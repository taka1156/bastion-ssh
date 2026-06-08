FROM ubuntu:latest

WORKDIR /workspace

ENV LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja \
    LC_ALL=ja_JP.UTF-8 \
    TZ=Asia/Tokyo

RUN <<-EOF
apt-get update
apt-get install -y --no-install-recommends \
  rsync \
  bash-completion \
  git \
  git-lfs \
  curl \
  make \
  locales \
  ansible \
  ansible-lint

rm -rf /var/lib/apt/lists/*

curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -o /usr/bin/cloudflared
chmod +x /usr/bin/cloudflared

curl -L https://github.com/secretlint/secretlint/releases/download/v13.0.2/secretlint-13.0.2-linux-arm64 -o /usr/bin/secretlint
chmod +x /usr/bin/secretlint
EOF

RUN <<-EOF
echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen
locale-gen ja_JP.UTF-8
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
EOF

RUN git lfs install

RUN <<-EOF
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
echo "Asia/Tokyo" > /etc/timezone
EOF

RUN <<-EOF
curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -o ~/.git-completion.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

echo "[ -f ~/.git-prompt.sh ] && source ~/.git-prompt.sh" >> ~/.bashrc
echo "[ -f ~/.git-completion.sh ] && source ~/.git-completion.sh" >> ~/.bashrc
echo "GIT_PS1_SHOWDIRTYSTATE=true" >> ~/.bashrc
echo "GIT_PS1_SHOWUNTRACKEDFILES=true" >> ~/.bashrc
echo "GIT_PS1_SHOWUPSTREAM=auto"  >> ~/.bashrc
git config --system --add safe.directory /workspace
echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[01;33m\] \w \[\033[01;31m\]\$(__git_ps1 \"(%s)\") \\n\[\033[01;34m\]\\$ \[\033[00m\]"' >> ~/.bashrc
EOF

CMD ["bash"]
