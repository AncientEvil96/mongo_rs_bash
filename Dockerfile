FROM mongo

ENV TZ=Europe/Moscow

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -y && \
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


# mongosh
RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add - && \
    sudo apt-get install gnupg && \
    wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add - 

RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list


RUN cd /usr/bin && \
    sudo ln -s python3 python && \
    python3 -m pip install --upgrade pip

# create user
RUN useradd -m mongouser && \
    echo "mongouser:supergroup" | chpasswd && \
    adduser mongouser sudo && \
    echo "mongouser     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 

EXPOSE 27017