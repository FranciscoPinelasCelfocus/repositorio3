FROM alpine:3.8
MAINTAINER jorge.milhazes.pereira@gmail.com

RUN apk -U add git
RUN git config --global user.email "jorge.milhazes.pereira@gmail.com" && git config --global user.name "jorgemilhazespereira"
