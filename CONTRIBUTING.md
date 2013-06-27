Thanks for considering to contribute to this library!

A few things to note: 

If you are working on a backend, you should run the specs with BACKEND set to 
your particular backend. This tells the specs to create the correct backend. 

An example of this is if I was working on the DataMapper backend, I would run 
the specs as follows. 

``` sh
BACKEND=data_mapper rake spec
```

If you want to run the full spec suite with all the backends, you can run: 

``` sh
rake integration
```

This will iterate over the backends one-by-one and run the specs. 
