FROM alpine:latest

RUN apk add --no-cache bash neovim ttyd ripgrep fd git gcc musl-dev tree


#setting up a restricted shell to restrict users to use only whitelisted commands
RUN ln -s /bin/bash /bin/rbash
RUN adduser -D -s /bin/rbash visitor

#set up command whitelist 
RUN mkdir -p /home/visitor/white_bin

RUN ln -s /bin/ls /home/visitor/white_bin/ls
RUN ln -s /bin/cat /home/visitor/white_bin/cat
RUN ln -s /bin/grep /home/visitor/white_bin/grep
RUN ln -s /bin/date /home/visitor/white_bin/date
RUN ln -s /usr/bin/clear /home/visitor/white_bin/clear
RUN ln -s /usr/bin/tree /home/visitor/white_bin/tree
RUN ln -s /usr/bin/file /home/visitor/white_bin/file
RUN ln -s /usr/bin/whoami /home/visitor/white_bin/whoami
RUN ln -s /usr/bin/uptime /home/visitor/white_bin/uptime

# crate a .bash_profile in the home folder so the $PATH gets redefined to the whitelist
RUN echo "export PATH=/home/visitor/white_bin" > /home/visitor/.bash_profile
# lock down the file so the user can only read/access the path of the whitelisted commands and not modify it
RUN chown root:root /home/visitor/.bash_profile && chmod 644 /home/visitor/.bash_profile

WORKDIR /home/visitor/portfolio

COPY --chown=visitor:visitor ./files .
COPY --chown=visitor:visitor ./config /home/visitor/.config/nvim

# switch to visitor user but fetch and update nvim plugins with superuser privileges before permission loss
RUN su visitor -s /bin/sh -c "nvim --headless '+Lazy! sync' +qa"

# create locked down shell to use in nvim's init.lua to catch ':terminal'/ SPACE + t
RUN echo '#!/bin/bash' > /bin/portfolio-shell && \
    echo 'export PATH=/home/visitor/white_bin' >> /bin/portfolio-shell && \
    echo 'exec /bin/rbash' >> /bin/portfolio-shell && \
    chmod 755 /bin/portfolio-shell

USER visitor
EXPOSE 7681

ENV XDG_STATE_HOME=/tmp/state
ENV XDG_CACHE_HOME=/tmp/cache
ENV NVIM_RPLUGIN_MANIFEST=/tmp/rplugin.vim

# finally run ttyd and nvim with the tree-explorer and README file open 
CMD ["ttyd", "-t", "fontSize=18" ,"-t","theme={\"background\": \"#1e1e2e\"}", "-W", "-p", "7681", "nvim", "-R", "-n", "README.md", "+NvimTreeOpen"]

