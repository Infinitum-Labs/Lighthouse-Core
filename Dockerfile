FROM ubuntu

WORKDIR /usr/src/lighthouse_core
COPY . .

# Install Dependencies
RUN mkdir ../flutter
RUN git clone --depth=1 --branch 3.7.5 https://github.com/flutter/flutter.git ../flutter
RUN export PATH="$PATH:`pwd`/flutter/bin"
RUN flutter pub get

# Run the Build
CMD [ "flutter", "run", "-d", "chrome", "--web-port 8080" ]