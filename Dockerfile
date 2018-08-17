FROM ruby
WORKDIR /
ADD . /
RUN apt-get update && apt-get install -y build-essential cmake
RUN wget https://github.com/ku-nlp/jumanpp/releases/download/v2.0.0-rc2/jumanpp-2.0.0-rc2.tar.xz
RUN tar xvf jumanpp-2.0.0-rc2.tar.xz
RUN mkdir jumanpp-2.0.0-rc2/build
RUN cd jumanpp-2.0.0-rc2/build && cmake ../ && make -j 8 && make install && cd ../../ && rm -rf jumanpp-2.0.0-rc2.tar.xz jumanpp-2.0.0-rc2
RUN gem install bundler && bundle install
EXPOSE 2345
CMD ["rake", "run"]
