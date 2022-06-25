module multiplexer(
    input in_0,
    input in_1,
    input in_2,
    input in_3,
    input sel_0,
    input sel_1,
    output Q
);

wire n_0;
wire n_1;

wire and_0, and_1, and_2, and_3;


assign n_0 = ~sel_0;
assign n_1 = ~sel_1;

assign and_0 = in_0 & n_0 & n_1;
assign and_1 = in_1 & sel_0 & n_1;
assign and_2 = in_2 & sel_1 & n_0;
assign and_3 = in_3 & sel_1 & sel_0;
assign Q = and_0 | and_1 | and_2 | and_3



endmodule