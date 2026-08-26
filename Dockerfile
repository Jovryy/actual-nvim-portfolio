FROM alpine:latest

RUN apk add --no-cache neovim ttyd ripgrep fd git gcc musl-dev tree

#disable shell
RUN adduser -D -s /bin/false visitor

WORKDIR /home/visitor/portfolio

COPY --chown=visitor:visitor ./files .
COPY --chown=visitor:visitor ./config /home/visitor/.config/nvim

USER visitor

RUN nvim --headless '+Lazy! sync' +qa

USER root
RUN rm -f /bin/sh /bin/ash # removing any shell program that could be used tp bring havoc if nvim were escaped from...

USER visitor
EXPOSE 7681

ENV XDG_STATE_HOME=/tmp/state
ENV XDG_CACHE_HOME=/tmp/cache
ENV NVIM_RPLUGIN_MANIFEST=/tmp/rplugin.vim

# finally run ttyd and nvim with the tree-explorer and README file open 
CMD ["ttyd", "-t", "fontSize=18" ,"-t","theme={\"background\": \"#1e1e2e\"}", "-t", "titleFixed=Joel's Portfolio", "-W", "-p", "7681", "nvim", "-R", "-n", "README.md", "+NvimTreeOpen"]

