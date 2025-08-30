FROM ruby:3.4.5

WORKDIR /app

COPY Gemfile Gemfile.lock .
RUN bundle install
COPY . .

ENTRYPOINT ["./entrypoint.sh"]

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
