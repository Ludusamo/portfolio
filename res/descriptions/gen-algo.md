Genetic Algorithm Stardew was created with the motivation to learn about
genetic algorithms while applying it to a problem that I wanted to try solving.

This was a fun project that was written in C. It uses SDL for graphics rendering
and gave me a nice introduction to implementing and solving problems using
a genetic algorithm.

This project also allowed me to try some multithreading by separating my
graphics rendering and my updating of the algorithm to enhance the performance.

Further details can be found on my blog beginning with this
[blog post](http://ludusamo.com/Blog/side-project-genetic-algorithms/index.html).

If you would like to try the application, you can pull down the source code from
Github and build the project. It has dependencies on SDL2. Alternatively, you
can check out [this](http://ludusamo.com/Genetic-Algorithm-Stardew/) version
built with [Emscripten](http://kripken.github.io/emscripten-site/)
and hosted in the web. It is slower due to being unable to make use of
multithreading, but it is a very useful demonstration.

[Github](https://github.com/Ludusamo/Genetic-Algorithm-Stardew)
[Demo](http://ludusamo.com/Genetic-Algorithm-Stardew/)
