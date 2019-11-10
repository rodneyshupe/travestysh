# Travesty in Bash

A simple project for me to play with Bash.  It makes no sense to do a application like this in BASH but was more of a fun thing to do.  This analyzes input text and then randomly generates text output based on the pattern probability.

My first exposure to this algorithm was via a Pascal version published in [BYTE November 1984](https://www.scribd.com/doc/99613420/Travesty-in-Byte) ([alt reference](https://archive.org/stream/byte-magazine-1984-11/1984_11_BYTE_09-12_New_Chips#page/n129/mode/2up)).  Since then I have implemented this algorithm to learn new languages.

## Algorithm

This is a free interpretation of the Travesty algorithm by Hugh Kenner and Joseph O'Rourke discussed in BYTE based on the paper "[Richard A. O’Keefe - An introduction to Hidden Markov Models](www.cs.otago.ac.nz/cosc348/hmm/hmm.pdf)".

From this paper:
> A kth-order travesty generator keeps a “left context” of k symbols. Here k = 3, one context is “fro”. At each step, we find all the places in the text that have the same left context, pick one of them at random, emit the character we find there, and shift the context one place to the left. For example, the text contains “(fro)m”, so we emit “m” and shift the context to “rom”. The text contains “p(rom)ise”, so we emit “i” and shift the context to “omi”. The text contains “n(omi)nation”, so we emit “n” and shift the context to “min”. The text contains “(min)e”, so we emit “e” and shift the context to “ine”. And so we end up with “fromine”.
>
> How is this a Markov chain? The states are (k + 1)-tuples of characters, only those substrings that actually occur in our training text. By looking at the output we can see what each state was. There is a transition from state s to state t if and only if the last k symbols of s are the same as the first k symbols of t, and the probability is proportional to the number of times t occurs in the training text.
>
> A Travesty generator can never generate any (local) combination it has not seen; it cannot generalise"

## Getting Started

After cloning the repo you can quickly run with the following:
```sh
sh travesty.sh sample.txt
```

## Application Usage

Display usage message with `sh travesty.sh --help`

```
USAGE:
    travestyrs [FLAGS] [OPTIONS] [INPUT]

FLAGS:
    -d, --debug      Number of characters to output.
    -h, --help       Prints help information
        --verse      Sets output to verse mode, defaults to prose
    -V, --version    Prints version information

OPTIONS:
    -b, --buffer-size <buffer_size>          The size of the buffer to be analyzed. The larger this is the slower the
                                             output will appear
    -l, --line-width <line_width>            Approximate line length of the output
    -o, --output-size <out_chars>            Number of characters to output
    -p, --pattern-length <pattern_length>    Pattern Length

ARGS:
    <INPUT>    Sets the input file to use
```

## Attributions:
`sample.txt` - Extract from [bbejeck](https://github.com/bbejeck/hadoop-algorithms/blob/master/src/shakespeare.txt)
`adventure.txt` - Extract from Crowther, Will, and D. Woods. [Adventure](http://mirror.ifarchive.org/if-archive/games/source/adv350-pdp10.tar.gz) (aka "ADVENT" and "Colossal Cave") FORTRAN source code. 1977.
