FROM cloudfoundry/cflinuxfs3

COPY \
       om \
       semver \
       cf \
       pivnet \
       stemcell-downloader \
       jq \
       terraform \
       spruce \
       bosh \
       yq \
       tile-config-generator \
       cf-mgmt \
       cf-mgmt-config \
       bbr \
       credhub \
       uaa \
       ytt \
       kapp \
       dnscontrol \
       yasak \
       update-yaml-value \
       vars-to-credhub \
       /usr/local/bin/

RUN \
# Remove unnecessary packages with CVEs reported by our Clair image scanning in Harbor
 apt-get -y remove --purge "subversion" "libaudiofile1" "libwebp6" "mercurial" "imagemagick" "libopenjp2-7" && \
 apt-get -y autoremove --purge

# When in need for man pages, we may stop excluding them
#RUN rm /etc/dpkg/dpkg.cfg.d/excludes

RUN \
\
# Install the add-apt-repository CLI
 apt-get update -qq && \
 apt-get -y install --no-install-recommends "software-properties-common" "gpg-agent" && \
\
\
\
 distrib_codename=$(lsb_release -cs) && \
\
# Azure Client & sqlcmd
 echo "deb https://packages.microsoft.com/repos/azure-cli ${distrib_codename} main" \
    | tee "/etc/apt/sources.list.d/azure-cli.list" && \
 curl --fail --show-error --silent --location \
        --url "https://packages.microsoft.com/keys/microsoft.asc" \
    | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="it-s-okay" \
        apt-key --keyring "/etc/apt/trusted.gpg.d/microsoft.gpg" add "-" && \
\
# certbot
 add-apt-repository "universe" && \
 add-apt-repository "ppa:certbot/certbot" && \
\
# sqlcmd
 curl --fail --show-error --silent --location \
    --url "https://packages.microsoft.com/config/ubuntu/18.04/prod.list" \
    --output "/etc/apt/sources.list.d/microsoft.list" && \
\
# gcloud SDK
 echo "deb http://packages.cloud.google.com/apt ${distrib_codename} main" \
    | tee "/etc/apt/sources.list.d/google-cloud.list" && \
 curl --fail --show-error --silent --location \
        --url "https://packages.cloud.google.com/apt/doc/apt-key.gpg" \
    | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="it-s-okay" \
        apt-key --keyring "/etc/apt/trusted.gpg.d/google-cloud.gpg" add "-" && \
\
\
\
# mutualized update of Aptitude repositories
 apt-get update -qq && \
\
\
\
# pip
 apt-get -y install --no-install-recommends python-pip python-dev python-setuptools && \
\
# git-lfs
 apt-get -y install --no-install-recommends git-lfs && \
\
# pigz: Parallel Implementation of GZip
 apt-get -y install --no-install-recommends pigz && \
\
# vim
 ln -s /usr/bin/vim.tiny /usr/local/bin/vim && \
\
# UAA Client
 apt-get -y install --no-install-recommends "ruby-dev" && \
 gem install cf-uaac --no-ri --no-rdoc && \
\
# Ensure latest version of six
 pip install six --upgrade && \
\
# Azure Client
 apt-get -y install --no-install-recommends "apt-transport-https" "azure-cli" && \
\
# gcloud SDK
 apt-get -y install --no-install-recommends "google-cloud-sdk" && \
\
# envsubst
 apt-get -y install --no-install-recommends "gettext-base"

# # Golang
#  apt-get -y install --no-install-recommends "golang-1.13"

# ENV GOROOT="/usr/lib/go-1.13"
# ENV GOPATH="/usr/local"
# ENV PATH="${GOROOT}/bin:${PATH}"
# RUN \
# Ginkgo
#  go get github.com/onsi/ginkgo/ginkgo && \
#  go get github.com/onsi/gomega/...

RUN \
# Clean up
 apt-get remove -y python-dev apt-transport-https && \
 apt-get -y clean && apt-get -y autoremove --purge && \
 #rm -rf /etc/apt/ && \
 rm -rf /tmp/* && \
 find /var/lib/apt/lists -type f -delete && \
 find /var/cache/debconf -type f -name '*-old' -delete && \
 find /var/log -type f -user root -delete
