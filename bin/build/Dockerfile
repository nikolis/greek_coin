FROM ubuntu:18.04

ENV LANG=en_US.UTF-8 \
    HOME=/home/nikolis/git/greek_coin/bin/build \
    TERM=xterm

WORKDIR /home/nikolis/git/greek_coin/bin/build

RUN \
  apt-get update -y && \
  apt-get install -y git wget vim locales && \
  apt-get install gnupg gnupg1 gnupg2\
  locale-gen en_US.UTF-8 && \
  wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
  dpkg -i erlang-solutions_1.0_all.deb && \
  rm erlang-solutions_1.0_all.deb && \
  apt-get update -y && \
  apt-get install -y erlang elixir

CMD ["/bin/bash"]
