FROM ruby:3.4.5

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .

CMD ["bin/rails", "s", "-b", "0.0.0.0"]
