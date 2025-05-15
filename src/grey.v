module Gray_counter #(
  parameter SIZE = 4
) (
  input clk,
  input rst,
  input inc,
  output [SIZE-1:0] gray
);

reg [SIZE-1:0] bin_counter;

always @(posedge clk) begin
  if    (rst) bin_counter <= {SIZE{1'b0}};
  else if (inc) bin_counter <= bin_counter + 1'b1;
end

wire [SIZE-1:0] gray_change = bin_counter >> 1 ^ bin_counter;

assign gray = gray_change;

endmodule
