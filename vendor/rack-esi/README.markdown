[ESI]: http://www.w3.org/TR/esi-lang
[Rack::Cache]: http://tomayko.com/src/rack-cache/

TODO: Improve this text.

# Rack::ESI

Rack::ESI is an implementation of a small (but still very useful!) subset of [ESI][].

It allows you to _easily_ cache everything but the user-customized parts of your dynamic pages without leaving the comfortable world of Ruby when used together with [Ryan Tomayko's Rack::Cache][Rack::Cache].

Development of Rails::ESI has just begun and it is not yet ready for anything but exploration.

## Currently Supported Expressions

* `<esi:include src="..."/>` where `src` is a relative URL to be handled by the Rack application.
* `<esi:remove>...</esi:remove>`
* `<esi:comment text="..."/>`

## Examples

    rackup examples/basic_example_application.ru

With [Rack::Cache][]:

    rackup examples/basic_example_application_with_caching.ru

## TODOs and FIXMEs

    rake tasks        # Show TODOs and FIXMEs
    rake tasks:fixme  # Show FIXMEs
    rake tasks:todo   # Show TODOs
