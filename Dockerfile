FROM almalinux:8

RUN yum -y update && yum -y install ca-certificates nss

ADD iRedMail.repo /etc/yum.repos.d/iRedMail.repo
ADD iRedMail /usr/src/iRedMail/

ARG VERSION="1.6.74"
ARG RELEASE_DATE="2020-04-02"
ARG RELEASE_DATE_SIGN=""

LABEL onlyoffice.mailserver.release-date="${RELEASE_DATE}" \
      onlyoffice.mailserver.version="${VERSION}" \
      onlyoffice.mailserver.release-date.sign="${RELEASE_DATE_SIGN}" \
      description="Mail Server is an open-source mail server solution that allows connecting your own domain name to ONLYOFFICE collaboration platform,as well as creating and managing corporate mailboxes." \
      maintainer="Ascensio System SIA <support@onlyoffice.com>" \
      securitytxt="https://www.onlyoffice.com/.well-known/security.txt"

RUN yum -y update
RUN yum -y install yum-plugin-ovl
RUN yum clean metadata
RUN sed -i "s/tsflags=nodocs//g" /etc/yum.conf
RUN yum -y --disablerepo=rpmforge,ius,remi install epel-release
RUN yum -y install tar wget curl htop nano gcc make perl
RUN wget https://www.openssl.org/source/openssl-1.1.1f.tar.gz
RUN tar -zxf openssl-1.1.1f.tar.gz
RUN cd openssl-1.1.1f/
RUN ./config
RUN make
RUN make install
RUN cd ..
RUN rm -f openssl-1.1.0f.tar.gz
RUN mv /usr/bin/openssl /root/ 
RUN ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
RUN echo '/usr/local/lib64' >> /etc/ld.so.conf
RUN ldconfigRUN yum -y install postfix mysql-server mysql perl-DBD-MySQL mod_auth_mysql
RUN yum -y install php php-common php-gd php-xml php-mysql php-ldap php-pgsql php-imap php-mbstring php-pecl-apc php-intl php-mcrypt
RUN yum -y install httpd mod_ssl cluebringer dovecot dovecot-pigeonhole dovecot-managesieve
RUN yum -y install amavisd-new clamd clamav-db spamassassin altermime perl-LDAP perl-Mail-SPF unrar
RUN yum -y install python-sqlalchemy python-setuptools MySQL-python python-pip awstats
RUN yum -y install libopendkim libopendkim-devel mysql-devel readline-devel gcc-c++ sendmail-milter sendmail-devel libbsd-devel
RUN yum -y install readline libyaml-devel libffi-devel openssl-devel bison
RUN yum -y install curl-devel httpd-devel sqlite-devel which libtool unzip bzip2 acl patch tmpwatch crontabs dos2unix logwatch crond imapsync opendbx-mysql
RUN find /usr/src/iRedMail -type d -name pkgs -prune -o -type f -exec dos2unix {} \;
RUN chmod 755 /usr/src/iRedMail/pkgs_install.sh
RUN chmod 755 /usr/src/iRedMail/iRedMail.sh
RUN chmod 755 /usr/src/iRedMail/run_mailserver.sh 
RUN chmod 755 /usr/src/iRedMail/install_mail.sh 
RUN bash /usr/src/iRedMail/pkgs_install.sh
RUN mkdir -p /etc/pki/tls/mailserver /var/vmail
RUN pip install -r /usr/src/iRedMail/tools/scripts/requirements.txt
RUN openssl dhparam -out /etc/pki/tls/dhparams.pem 1024

VOLUME ["/var/log"]
VOLUME ["/var/lib/mysql"]
VOLUME ["/var/vmail"]
VOLUME ["/etc/pki/tls/mailserver"]

EXPOSE 25
EXPOSE 143
EXPOSE 587
EXPOSE 465
EXPOSE 993
EXPOSE 995
EXPOSE 8081
EXPOSE 3306
EXPOSE 4190

CMD export CONFIGURATION_ONLY='YES' && \
    export USE_DOCKER='YES' && \
    bash -C '/usr/src/iRedMail/install_mail.sh';
