FROM debian:testing

LABEL maintainer Andrea Bagnacani <andrea.bagnacani@gmail.com>

RUN echo "deb http://httpredir.debian.org/debian stable main" > /etc/apt/sources.list.d/stable.list
RUN apt-get update && apt-get install --no-install-recommends -y \
    python2.7 \
    python2.7-minimal \
    libpython2.7-stdlib \
    libpython2.7-dev \
    python-pip \
    python-flask \
    python-jinja2 \
    libgomp1 \
    libgsl2 \
    gcc \
    git \
    wget \
    && apt-get clean
RUN pip install --upgrade pip
RUN pip install setuptools wheel
RUN git config --global http.sslverify false

# install ViennaRNA core
RUN wget https://www.tbi.univie.ac.at/RNA/download/debian/debian_9_0/viennarna_2.4.10-1_amd64.deb
RUN dpkg -i viennarna_2.4.10-1_amd64.deb
RUN rm viennarna_2.4.10-1_amd64.deb

# install ViennaRNA python bindings
RUN wget https://www.tbi.univie.ac.at/RNA/download/debian/debian_9_0/python-rna_2.4.10-1_amd64.deb
RUN dpkg -i python-rna_2.4.10-1_amd64.deb
RUN rm python-rna_2.4.10-1_amd64.deb

# install ViennaRNA development files
RUN wget https://www.tbi.univie.ac.at/RNA/download/debian/debian_9_0/viennarna-dev_2.4.10-1_amd64.deb
RUN dpkg -i viennarna-dev_2.4.10-1_amd64.deb
RUN rm viennarna-dev_2.4.10-1_amd64.deb

# install ViennaRNA forgi
RUN git clone https://github.com/ViennaRNA/forgi.git
WORKDIR forgi
RUN pip install subprocess32
RUN pip install -r requirements.txt
RUN python setup.py install
WORKDIR /
RUN rm -rf forgi

# remove unused packages
RUN apt-get autoremove -y \
    git \
    wget \
    python-pip

# install ViennaRNA forna for TriplexRNA
COPY forna* /forna/
COPY htdocs/ /forna/htdocs/

# set environment
ENV PYTHONPATH /usr/lib/python2.7/dist-packages:/usr/local/lib/python2.7/dist-packages:forna

# launch forna
EXPOSE 8080
ENTRYPOINT ["/forna/forna_server.py", "-p", "8080", "-o", "0.0.0.0", "-s"]
CMD ["/forna/forna_server.py", "-p", "8080", "-o", "0.0.0.0", "-s"]
