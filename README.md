# What is this?
This is a C/C++ implementation for SDLang.

# Dependencies
- C++17 compliant compiler
- [Genivia RE/Flex 3.2](https://github.com/Genivia/RE-flex)
  - *not* [invisible-island reflex](https://invisible-island.net/reflex/reflex.html), they are two completely separate projects
  - Used only if you regenerate the lexer, still optional
  - We have a copy in the source so it will try to build it by default.
- Bison 3.8
  - Used only if you regenerate the parser.

# What works
- parsing
  - tags are supported (including semicolon delimited)
  - strings (escaped or wysiwyg)
  - binary (via base64)
  - all integer types
  - all float types
  - children are supported
  - attributes are supported

# Missing Features
- date
- timestamp
- datetime
  - These are *not* easy to support because they require timezone support which, somehow in 2023, is still a mess on various systems. You would be *miles* ahead by supporting your own datetime format and handling timezones on your own. I [tried](https://github.com/microsoft/icu/issues/125) [supporting](https://github.com/HowardHinnant/date/issues/771#issuecomment-1399313886) timezones and ultimately, I determined that the best way to handle timezones at this time depends heavily on the application being written because the system isn't a reliable source for timezone information. Sometimes being unreliable is still good enough, other times it's very much not good enough. You *need* to make that decision yourself, at least until everyone can get on the same page (which, let's be honest, probably isn't going to happen).
- generator

# Potential Improvements
- While I like Genivia/RE-flex, the creators appear to be a touch stubborn in the way of distribution and naming. Basically, they won't do work to make the tool more public, nobody knows the tool exists. Even if they've heard of it, they're probably talking about a different reflex tool that's somehow less used but more popular on Google. I don't like shipping tools and libraries in my own source. So if the oppurtunity arises, I think moving off of Genivia/RE-flex might be worth it.

- Even some basic tests are missing. I've run some rudimentary tests to make sure things at least function but haven't automated them.

- There isn't much of an API for fetching information efficiently at the moment. It basically assumes you read everything into memory and query it as a hash table. That's probably find most of the time but a streaming parser could be nice.

# Building
If your goal is to simply build, you can do something like:
```
cd <saddle source dir>
mkdir build
cd build
cmake .. -G"Ninja Multi-Config"
cmake --build .
```
and it should just work.