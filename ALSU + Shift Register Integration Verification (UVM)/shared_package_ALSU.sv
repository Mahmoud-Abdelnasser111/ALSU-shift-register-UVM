package  shared_package_ALSU;

typedef enum  {RIGHT , LEFT} direction_e;
typedef enum bit [2:0] {OR=0, XOR=1, ADD=2, MULT=3, SHIFT=4, ROTATE=5, INVALID_6=6, INVALID_7=7} opcode_e;
typedef enum {MAXPOS=3, ZERO=0, MAXNEG=-4} corner_case_e;
typedef enum bit [2:0] {first = 3'b001, second = 3'b010, third = 3'b100} one_bit_high_e;

    
endpackage