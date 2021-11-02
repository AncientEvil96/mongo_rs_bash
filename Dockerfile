FROM mongo

ENV TZ=Europe/Moscow
# ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE = 1
# ARG DEBIAN_FRONTEND=noninteractive

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# RUN curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add - && \
#     echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list && \

RUN apt-get update -y && \
    # apt install -y apt-utils && \
    apt-get upgrade -y && \
    apt-get install -y \
    vim \
    mc \
    wget \
    ssh \
    less \
    unzip \
    sudo \
    python3-pip \ 
    curl \
    iputils-ping \ 
    net-tools \
    mongodb-mongosh 
    # systemd


# mongosh
RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add - && \
    sudo apt-get install gnupg && \
    wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add - 

RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list


RUN cd /usr/bin && \
    sudo ln -s python3 python && \
    python3 -m pip install --upgrade pip

# #mongodb
# RUN curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add - && \
#     echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list && \
#     sudo apt-get -y update && \
#     sudo apt-get -y install mongodb-org && \ 
#     sudo service start mongod.service && \
#     sudo service enable mongod && \
#     sudo service start mongod

# create user
RUN useradd -m mongouser && \
    echo "mongouser:supergroup" | chpasswd && \
    adduser mongouser sudo && \
    echo "mongouser     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 

# RUN mkdir /home/mongouser
# RUN touch /home/mongouser/mongod/mongod.conf

# USER mongouser

EXPOSE 27017

