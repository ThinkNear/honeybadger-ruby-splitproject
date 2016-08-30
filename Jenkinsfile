#!groovy

rubyGem {
    test_script = """
    #!/bin/bash -l
    rvm use .
    bundle install
    bundle exec rspec spec
    ""

    build_script = 'gem build honeybadger-ruby-splitproject.gemspec'
}
