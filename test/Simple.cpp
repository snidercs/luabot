
#include <iostream>

namespace bot {

class Simple {
public:
    Simple() { std::cout << "Simple()" << std::endl; }
    ~Simple() { std::cout << "~Simple()" << std::endl; }
    void hello() {
        std::cout << msg << std::endl;
    }
    std::string msg {"hello, world" };
};
}

extern "C" {

typedef void BOT_Simple;
BOT_Simple* bot_Simple_new() {
    return new bot::Simple();
}

void bot_Simple_free (BOT_Simple* self) {
    delete (bot::Simple*)self;
}

void bot_Simple_hello (BOT_Simple* self) {
    ((bot::Simple*)self)->hello();
}

}
