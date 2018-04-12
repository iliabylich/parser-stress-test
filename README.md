A collection of scripts for the Parser gem.

Next sections assume that your version of Ruby is `2.5.1`, but it's not
necessary, scripts work with any version of Ruby (I guess).

``` sh
$ ruby -v
2.5.1
```

### `rake gems:download`

It downloads and unpacks all gems available on the rubygems.org
and saves them to the `gems/` directory. It uses "buckets" of two first letters of the gem name,
so `rails`, for example will be in the `gems/ra/rails-x.y.z` directory.

It also checks for local files before downloading any gem, which literally
means that you may abort this task and run it again to continue downloading.

NOTE: it downloads gems in 20 threads and depends on the `concurrent-ruby` gem.
Run `bundle install` before running this task.

### `rake filelist:generate`

This task generates a list of all `.rb` files in the `gems/` directory
and saves it to the `filelist` file (excluded from the source control).

NOTE: this task doesn't depend on any libraries, you can run it with any version of Ruby on the clean env.

### `rake mri:parse`

It runs `Ripper` on every file from the `filelist` and saves valid files to the
`valid-for-x.y.z` file.

NOTE: this task doesn't depend on any libraries, you can run it with any version of Ruby.

### `rake parser:parse`

This task takes two env variables:

1. `VERSION` - version of the parser you want to check, for example `25` for `2.5.1`.
2. `FILELIST` - path to the filelist of valid Ruby 2.5.1 sources.

It prints to the STDOUT all errors that occur during parsing.

NOTE: this task obviously depends on the Parser gem.
Run `bundle install` before running this task.

### Running everything

For 2.5.1:

``` sh
$ ruby -v
2.5.1

$ rake gems:download
# a lot of output...

$ rake filelist:generate
# creates a "filelist" file

$ rake mri:parse
# creates a "valid-for-2.5.1" file

$ VERSION=25 FILELIST=valid-for-2.5.1 rake parser:parse
# prints errors (if any)
```
