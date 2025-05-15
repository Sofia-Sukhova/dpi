module test;

//Counter depth
parameter SIZE = 4;

import "DPI-C" function int grey_count( input int tick, input int size);

reg clk;
reg rst;
reg [SIZE - 1:0] res;

string filename;
string line;
int file;

int real_res;
int arg0;
int arg1;
int tick;
int rand_num;
reg dut_running;

reg inc;

Gray_counter #( .SIZE(SIZE)) counter (
  .clk (clk),
  .rst (rst),
  .inc (inc),
  .gray (res)
);

//make clk
initial
begin
    clk = 0;
    forever #1 clk = ~clk;
end

//task reset
task reset();
    rst = 0; @(negedge clk)
    rst = 1; @(negedge clk)
    rst = 0;
endtask


//test function
task test_input();
    reset();
    dut_running = 1;
    $display("Testing counter from %d on %d ticks", arg0, arg1);

    for ( tick = 0; tick < arg1 + arg0; tick ++) @(posedge clk)
    begin
	inc = 1;
        //this pause need for reaching internal arg0 state in actual GreyCounter
        if ( tick >= arg0)
        begin
            real_res = grey_count( tick, SIZE);
            if ( res != real_res)
            begin
                $display(" %d : %d != %d", tick, real_res, res);
                $fatal( 1, "Test failed!");
            end
        end
    end
    inc = 0;
    dut_running = 0;
    $display(" Test passed!");
endtask

//timeout
int timer;
parameter TIMEOUT=1000;

always @(posedge clk)
begin
    if (dut_running)
        timer <= timer + 1;
    else
        timer <= 0;

    if (timer == TIMEOUT + arg1 + arg0)
    begin
        $display("Timeout! DUT has been running too long.");
        $finish;
    end
end

//there is no boundaries except size of Counter
class RandState;
    rand bit [ SIZE-1:0] size;

    function int result();
	return size;
    endfunction
endclass

typedef enum
{
    NORM,
    OVER
} randTime;

class RandTime;
    rand bit [ SIZE - 1:0] norm_time;
    rand bit [ 1:0]	   wrap;
    
    rand randTime	   t_type;
    constraint t_type_range {
	t_type dist {
	    NORM := 10,
	    OVER := 5
	};
    }

    constraint on_wrap {
        solve t_type before wrap;
     	t_type == NORM -> wrap == 0;
	t_type == OVER -> wrap != 0;   
    }

    function int result();
	return { wrap, norm_time};
    endfunction
endclass 

//parsing input elements
initial
begin
    if ($value$plusargs("arg0=%d", arg0))
    begin
        if ($value$plusargs("arg1=%d", arg1))
        begin
            test_input();
        end
        else
        begin
            $display("Arg1 missed!");
        end
    end
    else if ($value$plusargs("file=%s", filename))
    begin
        file = $fopen(filename, "r");
        while ($fgets(line, file))
        begin
            $sscanf(line, "%d %d", arg0, arg1);
            test_input();
        end
    end
    else if ($value$plusargs("random_mode=%d", rand_num))
    begin
        if ( $test$plusargs("constraint"))
	begin
	    RandState r_state = new;
	    RandTime  r_time  = new;
	    for ( int i = 0; i < rand_num; )
	    begin
		reg ok;
		ok = r_state.randomize();
		if ( ok)
		begin
		    arg0 = r_state.result();
		end
		ok &= r_time.randomize();
		if ( ok)
		begin
		    arg1 = r_time.result();
		    i ++;
		    test_input();
		end
	    end
	end
	else
	begin
	    for (int i = 0; i < rand_num; i++)
            begin
                arg0 = $urandom();
                arg1 = $urandom();
                test_input();
            end
	end
    end
    else
    begin
	$display("wrong using");
    end
    $finish;
end

endmodule
