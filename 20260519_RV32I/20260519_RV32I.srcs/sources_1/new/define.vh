//OP-CODE instruction code [6:0]
`define R_TYPE 7'b011_0011


// R-type instruction
// {funct7,funct3} = 10bit
// `define ADD 10'b000_0000_000
// `define SUB 10'b010_0000_000
// `define SLT 10'b000_0000_010
// `define OR  10'b000_0000_110
// `define AND 10'b000_0000_111

// {funct7,funct3} = 4bit
`define ADD 4'b0000
`define SUB 4'b1000
`define SLL 4'b0001
`define SLT 4'b0010
`define SLTU 4'b0011
`define XOR 4'b0100
`define SRL 4'b0101
`define SRA 4'b1101
`define OR  4'b0110
`define AND 4'b0111
