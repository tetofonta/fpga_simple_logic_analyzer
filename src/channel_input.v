module channel_input(
    input i_clk,
    input [2:0] start_trigger_index,
    input start_trigger_edge,
    input _start_trigger_enable,
    input [2:0] end_trigger_index,
    input end_trigger_edge,
    input _end_trigger_enable,
    input manual_toggle,
    input [31:0] sample_limit,
    input do_sample_limit,
    input [31:0] time_prescaler,
    input _mrst,
    input [7:0] i_data,
    output save,
    output [31:0] data,
    output run
);

wire do_sampling;
wire trigger_status;
wire trigger_stop;
wire man_toggle_db;
wire [23 : 0] time_out;

debouncer man_tog_deb(
    .i_clk(i_clk),
    .button(manual_toggle),
    .signal(man_toggle_db)
);

channel_trigger trigger(
    .i_data(i_data),
    .i_clk(i_clk),
    .i_trig_start_select(start_trigger_index),
    .i_trig_start_edge(start_trigger_edge),
    ._enable_start(_start_trigger_enable),
    .i_trig_end_select(end_trigger_index),
    .i_trig_end_edge(end_trigger_edge),
    ._enable_end(_end_trigger_enable),
    .i_man_toggle(man_toggle_db),
    .i_rst_0(trigger_stop),
    ._i_rst_1(_mrst),
    .o_run(run),
    .o_trig(trigger_status)
);

assign do_sampling = trigger_status & _mrst;

pin_change_detector pcint(
    .i_clk(i_clk),
    .i_data(i_data),
    ._inhibit(do_sampling),
    .o_changed(save)
);

step_limiter limit(
    .do_step_limit(do_sample_limit),
    .step_limit(sample_limit),
    .i_run(do_sampling),
    .i_step(save),
    .i_reset(~_mrst),
    .i_clk(i_clk),
    .stop(trigger_stop)
);

time_stepper timer(
    .i_clk(i_clk),
    .prescaler(time_prescaler),
    .i_run(do_sampling),
    .o_time(time_out)
);

assign data = {time_out, i_data};

endmodule