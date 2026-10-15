`ifdef ASSERTIONS

// conecta as assertions aos respectivos modulos sem adicionar portas ou logica extra
bind scheduler scheduler_sva u_scheduler_sva (
    .clk         (clk),
    .rst         (rst),
    .cmd_valid   (cmd_valid),
    .cmd_ready   (cmd_ready),
    .busy        (busy),
    .done        (done),
    .debug_state (debug_state)
);

bind fsm fsm_sva u_fsm_sva (
    .clk         (clk),
    .rst         (rst),
    .mem_b_we    (mem_b_we),
    .mem_b_re    (mem_b_re),
    .load_a      (load_a),
    .load_b      (load_b),
    .exec_done   (exec_done),
    .debug_state (debug_state)
);

`endif
