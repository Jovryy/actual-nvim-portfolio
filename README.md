# An Actual NVIM Portfolio

As the name already suggests: it's a boilerplate to create your own terminal portfolio actually using your trusted Neovim.

If you want a demo, have a look at my [Portfolio](https://joel.volkwein.dev) :)

### Why?

I always wanted a terminal portfolio inside my browser. 
Am most definitely not a competent designer.
I like neovim.

So using neovim:
- allows you to have a simple UI that presents Markdown files in a professional yet unique way
- makes creating your own portfolio site super easy with not a lot to configure
- saves you from design headaches
- is easily expandable
- looks really cool :)

an `actual-nvim-portfolio` does exactly that :)


### Requirements

Linux, Docker, a Server (VPS with around 500MB-1GB of ram and a CPU :P ), and a Domain.

No really, you dont need much more...


### Installation

```bash
$ git clone https://github.com/Jovryy/actual-nvim-portfolio.git
$ cd actual-nvim-portfolio
$ docker-compose up -d --build 
```

Thats it. Your portfolio should be up (at least locally for now...)

On a production server you would still have to open your ports for http and https.



### Configuration

Since it is not a static site, it requires a server to run. I used an Oracle Cloud VPS, but you can use it on any server you want.

If you want to use Caddy as your reverse proxy, make sure to change `localhost` inside the Caddyfile so let's encrypt can correctly issue your SSL certificates. 



### How?

With using neovim there are quite a few challenges involved.

1. How does it display a neovim session inside a browser?
   - That is an easy one, simply use [ttyd](https://github.com/tsl0922/ttyd). Super easy to set up and run.
2. How does nvim look like this?
   - Themes and plugins are configured inside the [init.lua](https://github.com/Jovryy/actual-nvim-portfolio/blob/main/config/init.lua). It is using the Lazy.nvim plugin manager
3. How is it secured? See [Security](#security)



### Security

How is it secured? Nvim is known for easily being escapable, right?

Yes it is. Thats why, instead of focusing on making nvim as inescapable as possible I designed a zero trust architecture inside docker. 
1. The first measure against trolls was to start the Container as a readonly file system. No files can be created or written to.

   ```yaml
   read_only: true
   ```
   
2. `/tmp` is necessary for any temporary files Caddy or nvim may create, so it cannot be readonly. So technically, users could create files inside it.
   To limit the damage that could be done we set a hard limit of 10M for the tmpfs. Also, to make it harder to execute scripts we tell the filesystem to make scripts non-executable, so trolls couldn't execute `./scripts.sh` that easily
  ```yaml
  tmpfs:
      - /tmp:size=10M,noexec,nosuid
  ```

3. Since anyone could have opened a terminal session using e.g. :terminal, I removed all shell executables (/bin/sh, /bin/ash).
   ```Dockerfile
   USER root
   RUN rm -f /bin/sh /bin/ash # removing any shell program that could be used tp bring havoc if nvim were escaped from...
   USER visitor
   ```
3. We prohibited privilege escalation with our docker-compose.yml too.
   ```yaml
   security_opt: 
      - no-new-privileges:true #forbid system from granting higher privileges if vulnerability is exploited
   ```


Is it entirely secure? Absolutely NOT. 
Will it have any impact on my Portfolio? Maybe, if a troll really wants to he will find a way to DoS it.
Will it impact the Server? No. The container supplies the session with only 0.5 CPUs and 256M of ram, so even a forkbomb and ram exhaustions would have no impact on the server itself whatsoever.

What could be done to prevent trolls from jamming the site?
Kubernetes! :)

But will Kubernetes run reliably on 1GB of RAM and a single ocpu core? No. 
Sooo if you cheap out like me... don't expect the highest reliability :)
