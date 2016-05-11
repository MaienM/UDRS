# UDRS

UDRS stands for the Universal Document Rendering System. This is an ambition name, and the gem does not in any way live up to the expectations that the name creates.

What it does do, in short, is allow you to write a single template for a file, and then render that template to a number of formats.

Currently, the following formats are supported:
- PDF
- ESC/P (Epson receipt printers)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'udrs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install udrs

## Usage

Create a view in the normal location, with the `.udrs` extension. The use the methods provided in doc to create your document.

Example template:

```ruby
    udrs_document do |doc|
        doc.section('Hello world!')
        doc.subsection('Introduction to the world')
        doc.text('Lorem ipsum dolor sit amet')

        doc.table([:fit, :expand, :fit]) do |table|
            table.row(10, 'Lorem ipsum', 12.34)
            table.row do |row|
                row.cell(10)
                row.cell('Lorem ipsum dolor sit amet', style: :bold)
                row.cell(-12)
            end
        end

        doc.footer do
            doc.text('Copyright 1970 Anonymous', size: :small)
        end
    end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

