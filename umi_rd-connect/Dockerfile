#UMI_TAG=latest
#mkdir -p "${PWD}"/umi_rd-connect/tmp

FROM rd-connect.eu/httpd:latest
MAINTAINER Andrés Cañada Pallarés

ENV NODE_ENV=production
ENV PORT=3000

ARG UMIBRANCH=latest
ENV	UMI_CLONE=/var/www/user-management-interface
RUN yum -y install nodejs git
RUN git clone https://github.com/inab/rd-connect-user-management-interface.git $UMI_CLONE

WORKDIR "${UMI_CLONE}"

#RUN npm install
#ENV PATH="${PWD}/node_modules/.bin:$PATH"
#RUN	yum autoremove -y git
#RUN	yum clean all

EXPOSE $PORT

#ENTRYPOINT ["npm", "start"]

