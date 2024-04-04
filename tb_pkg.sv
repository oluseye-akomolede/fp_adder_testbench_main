`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2024 10:43:55 AM
// Design Name: 
// Module Name: tb_pkg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

interface adder_ifc
(
    input logic i_clk,
    input logic i_rst
);

            /*s_axis_a_tvalid : IN STD_LOGIC;
            s_axis_a_tready : OUT STD_LOGIC;
            s_axis_a_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_axis_b_tvalid : IN STD_LOGIC;
            s_axis_b_tready : OUT STD_LOGIC;
            s_axis_b_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            m_axis_result_tvalid : OUT STD_LOGIC;
            m_axis_result_tready : IN STD_LOGIC;
            m_axis_result_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)*/
    
    //bit i_clk;
    //bit i_rst;
    bit s_axis_a_tvalid; //input
    bit s_axis_a_tready;
    bit [15:0] s_axis_a_tdata;//input
    bit s_axis_b_tvalid;//input
    bit s_axis_b_tready;
    bit [15:0] s_axis_b_tdata;//input
    bit m_axis_result_tvalid;
    logic m_axis_result_tready;//input
    bit [15:0] m_axis_result_tdata;
    
    modport DUT 
    (
        output s_axis_a_tready, s_axis_b_tready, m_axis_result_tvalid, m_axis_result_tdata,
        input s_axis_a_tvalid, s_axis_a_tdata, s_axis_b_tvalid, s_axis_b_tdata, 
        input m_axis_result_tready,
        input i_clk, i_rst
    );
    
    clocking cbr @(posedge i_clk);
        input s_axis_a_tready, s_axis_b_tready;
        input m_axis_result_tvalid, m_axis_result_tdata;
        output s_axis_a_tvalid, s_axis_a_tdata, s_axis_b_tvalid, s_axis_b_tdata;
        output m_axis_result_tready;
        input i_clk, i_rst;
    endclocking: cbr
    
    clocking cbt @(negedge i_clk);
        input s_axis_a_tready, s_axis_b_tready;
        input m_axis_result_tvalid, m_axis_result_tdata;
        output s_axis_a_tvalid, s_axis_a_tdata, s_axis_b_tvalid, s_axis_b_tdata;
        output m_axis_result_tready;
        input i_clk, i_rst;
    endclocking: cbt
    
    modport TB_rx
    (
        clocking cbr
    );
    
    modport TB_tx
    (
        clocking cbt
    );
    
    

endinterface: adder_ifc
    
package tb_pkg;

    //Utility functions---------------------------------------------------------------------------
    `define SV_RAND_CHECK(r) \
        do begin \
            if(!(r)) begin \
                $display("%s:%0d: Randomization failed \"%s\"",\
                            `__FILE__, `__LINE__, `"r`"); \
                $finish; \
            end \
        end while(0)
        
    function bit[15:0] fp_add_16(input bit [15:0] a, input bit [15:0] b);
        bit [31:0] a_long;
        bit [31:0] b_long;
        bit [31:0] c_long;
        bit [15:0] c;
        real a_real;
        real b_real;
        real c_real;
        
        a_long = '0;
        b_long = '0;
        
        a_long[31:16] = a;
        b_long[31:16] = b;
        
        a_real = $bitstoshortreal(a_long);
        b_real = $bitstoshortreal(b_long);
        c_real = a_real + b_real;
        
        c_long = $shortrealtobits(c_real);
        c = c_long[31:16];
        return c;
        
        
    endfunction: fp_add_16
    //end utility functions-----------------------------------------------------------------------
    
    typedef virtual adder_ifc v_add_ifc;
    typedef virtual adder_ifc.TB_rx v_add_ifc_tbr;
    typedef virtual adder_ifc.TB_tx v_add_ifc_tbt;
    
    virtual class BaseTr;
        static int count;
        int id;
        
        function new();
            id = count++;
        endfunction
        
        pure virtual function bit compare(input BaseTr to);
        pure virtual function BaseTr copy(input BaseTr to = null);
        pure virtual function void display(input string prefix = "");     
    endclass: BaseTr
    
    //define the struct and transaction types. These will be generated and sent to the driver class
    typedef struct packed
    {
        bit s_axis_a_tvalid; 
        bit [15:0] s_axis_a_tdata;
        bit s_axis_b_tvalid;
        bit [15:0] s_axis_b_tdata;
        bit m_axis_result_tready;
    }adder_struct;
    
    typedef union packed
    {
        adder_struct as;
        bit [34 :0] mem;
    }adder_type;

    typedef class adder_output_cell;

    class adder_cell extends BaseTr;
        rand bit s_axis_a_tvalid; 
        rand bit [15:0] s_axis_a_tdata;
        rand bit s_axis_b_tvalid;
        rand bit [15:0] s_axis_b_tdata;
        rand bit m_axis_result_tready;
        extern function new();
        extern function void post_randomize();
        extern function bit compare(input BaseTr to);
        extern function void display(input string prefix = "");
        extern function adder_cell copy(input BaseTr to = null);
        extern function void pack(output adder_type to);
        extern function void unpack(input adder_type from);
        extern function adder_output_cell to_adder_output();
        
        constraint adder_values
        {
            s_axis_a_tdata inside {0, [15820:16230], [16256:17096]}; //0, 0.1:0.9, 1:100
            s_axis_b_tdata inside {0, [15820:16230], [16256:17096]}; //0, 0.1:0.9, 1:100
        }
        
        constraint always_enabled
        {
            s_axis_a_tvalid == 1;
            s_axis_b_tvalid == 1;
            m_axis_result_tready == 1;
            
        }
        
    endclass: adder_cell
    
    class adder_output_cell extends BaseTr;
        bit [15:0] m_axis_result_tdata;
        extern function new();
        extern function void post_randomize();
        extern function bit compare(input BaseTr to);
        extern function void display(input string prefix = "");
        extern function adder_output_cell copy(input BaseTr to = null);
    endclass: adder_output_cell
    //end transaction definitions----------------------------------------------------------------------------
    
    function adder_cell::new();
        
    endfunction: new
    
    function void adder_cell::post_randomize();
    endfunction: post_randomize
    
    function bit adder_cell::compare(input BaseTr to);
        adder_cell c;
        $cast(c,to);
        if (this.s_axis_a_tvalid != c.s_axis_a_tvalid) return 0;
        if (this.s_axis_a_tdata != c.s_axis_a_tdata) return 0;
        if (this.s_axis_b_tvalid != c.s_axis_b_tvalid) return 0;
        if (this.s_axis_b_tdata != c.s_axis_b_tdata) return 0;
        if (this.m_axis_result_tready != c.m_axis_result_tready) return 0;
        return 1;
    endfunction: compare
    
    function void adder_cell::display(input string prefix = "");
        adder_type p;
        $display("%sa_tvalid = %x, a_tdata = %x, b_tvalid = %x, b_tdata = %x, result_tready = %x",
                 prefix,
                 s_axis_a_tvalid,
                 s_axis_a_tdata,
                 s_axis_b_tvalid,
                 s_axis_b_tdata,
                 m_axis_result_tready);
                 
        this.pack(p);
//        $write("%s",prefix);
//        foreach(p.mem[i]) $write("%x ", p.mem[i]);
//        $display;          
    endfunction: display
    
    function adder_cell adder_cell::copy(input BaseTr to);
        if (to == null) copy = new();
        else $cast(copy,to);
        copy.s_axis_a_tvalid = this. s_axis_a_tvalid;
        copy.s_axis_a_tdata = this. s_axis_a_tdata;
        copy.s_axis_b_tvalid = this. s_axis_b_tvalid;
        copy.s_axis_b_tdata = this. s_axis_b_tdata;
        copy.m_axis_result_tready = this. m_axis_result_tready;
        
    endfunction: copy
    
    function void adder_cell::pack(output adder_type to);
        to.as.s_axis_a_tvalid = this.s_axis_a_tvalid;
        to.as.s_axis_a_tdata = this.s_axis_a_tdata;
        to.as.s_axis_b_tvalid = this.s_axis_b_tvalid;
        to.as.s_axis_b_tdata = this.s_axis_b_tdata;
        to.as.m_axis_result_tready = this.m_axis_result_tready;
    endfunction: pack
    
    function void adder_cell::unpack(input adder_type from);
        this.s_axis_a_tvalid = from.as.s_axis_a_tvalid;
        this.s_axis_a_tdata = from.as.s_axis_a_tdata;
        this.s_axis_b_tvalid = from.as.s_axis_b_tvalid;
        this.s_axis_b_tdata = from.as.s_axis_b_tdata;
        this.m_axis_result_tready = from.as.m_axis_result_tready;
    endfunction: unpack
    
    function adder_output_cell adder_cell::to_adder_output();
        adder_output_cell outp;
        outp = new();
        outp.m_axis_result_tdata = fp_add_16(this.s_axis_a_tdata,this.s_axis_b_tdata);
        return outp; 
    endfunction: to_adder_output
    
    
    function adder_output_cell::new();
    
    endfunction: new
    
    function void adder_output_cell::post_randomize();
    
    endfunction: post_randomize
    
    function bit adder_output_cell::compare(input BaseTr to);
    
        adder_output_cell c;
        $cast(c,to);
        if(this.m_axis_result_tdata != c.m_axis_result_tdata)return 0;
        
        return 1;
    
    endfunction:compare
    
    function void adder_output_cell::display(input string prefix = "");
        $display("%sresult_data = %x",prefix,
                 m_axis_result_tdata);
    endfunction: display
    
    function adder_output_cell adder_output_cell::copy(input BaseTr to = null);
        if (to == null) copy = new();
        else $cast(copy,to);
        copy.m_axis_result_tdata = this.m_axis_result_tdata;
    endfunction: copy
    
    
    
    //--------------------------------------------------------------------------------------------------
    
    //Config Class and all definitions. Config sets up environment parameters are randomizes them.------
    class env_config;
        int num_errors;
        int num_warnings;
        rand bit [31:0] num_ops; //total number of addition operations
        
        constraint c_num_ops_valid {num_ops > 0;}
        constraint c_num_ops_reasonable {num_ops < 1000;}
        
        extern function new();
        extern virtual function void display(input string prefix = "");
    endclass: env_config
    
    function env_config::new();
    endfunction: new
    
    function void env_config::display(input string prefix = "");
        $write("%sConfig: num_ops = %0d",prefix,num_ops);
        $display;
    endfunction: display
    //--------------------------------------------------------------------------------------------------
    
    //Generator class. Generates transactions based off of blueprints and uses mailboxes to pass to the driver class.
    class op_generator;
        adder_cell blueprint; //blueprint for generator
        mailbox gen2drv; //mailbox to driver for transactions
        event drv2gen; //event from our driver for once it's done
        int num_ops; //number of operations
        
        function new(input mailbox gen2drv,
                     input event drv2gen,
                     input int num_ops
                     );
                     
            this.gen2drv = gen2drv;
            this.drv2gen = drv2gen;
            this.num_ops = num_ops;
            blueprint = new();             
        endfunction: new     
        
        task run();
            adder_cell c;
            repeat(num_ops)
            begin
                `SV_RAND_CHECK(blueprint.randomize());
                $cast(c,blueprint.copy());
                c.display($sformatf("@%0t: Gen%0d: ", $time, 0));
                gen2drv.put(c);
                @drv2gen; //wait for the driver to finish with it
            end         
        endtask: run
        
    endclass: op_generator
    //--------------------------------------------------------------------------------------------------
    
    //Driver class and Driver callback class. Handles all driving of signals----------------------------
    typedef class driver_cbs;
    
    class driver;
        mailbox#(adder_cell) gen2drv; //for cells sent from generator
        event drv2gen; //tell generator when I am done with cell
        v_add_ifc_tbr rx; //virtual ifc for transmitting operands
        driver_cbs cbsq[$]; //Queue of callback objects 
        extern function new(input mailbox gen2drv,
                            input event drv2gen,
                            input v_add_ifc_tbr rx
                           );
        extern task run();
        extern task send(input adder_cell c);
    endclass: driver
    
    function driver::new(input mailbox gen2drv,
                         input event drv2gen,
                         input v_add_ifc_tbr rx
                        );
        this.gen2drv = gen2drv;
        this.drv2gen = drv2gen;
        this.rx = rx;
    endfunction: new
    
    task driver::run();
        adder_cell c;
        rx.cbr.s_axis_a_tvalid <= 0;
        rx.cbr.s_axis_a_tdata <= '0;
        rx.cbr.s_axis_b_tvalid <= 0;
        rx.cbr.s_axis_b_tdata <= '0;
        //rx.cbr.m_axis_result_tready <= 0;
        
        forever 
        begin
            //read transaction at the front of the mailbox
            gen2drv.peek(c);
            begin: tx
                //pre-transmit callbacks
                foreach(cbsq[i]) 
                begin
                    cbsq[i].pre_tx(this, c);
                end
                c.display($sformatf("@%0t: Drv%0d: ", $time,0));
                send(c);
                //post-transmit callbacks
                foreach(cbsq[i])
                begin
                    cbsq[i].post_tx(this,c);
                end
            end: tx
            gen2drv.get(c); //remove cell from the mailbox
            ->drv2gen;
        end
    endtask: run
    
    task driver::send(input adder_cell c);
//        adder_type pkt;
//        c.pack(pkt);
//        $write("Sending cell: ");
//        foreach(pkt.mem[i])
//            $write("%x ", pkt.mem[i]);
//        $display;
        c.display($sformatf("@%0tSending cell: ",$time));
        @(rx.cbr);
        while(rx.cbr.s_axis_a_tready !== 1 && rx.cbr.s_axis_b_tready !== 1)
        begin 
            @(rx.cbr); //loop until inputs are ready
            rx.cbr.s_axis_a_tvalid <= '0;
            rx.cbr.s_axis_a_tdata <= '0;
            rx.cbr.s_axis_b_tvalid <= '0;
            rx.cbr.s_axis_b_tdata <= '0;
        end
        rx.cbr.s_axis_a_tvalid <= c.s_axis_a_tvalid;
        rx.cbr.s_axis_a_tdata <= c.s_axis_a_tdata;
        rx.cbr.s_axis_b_tvalid <= c.s_axis_b_tvalid;
        rx.cbr.s_axis_b_tdata <= c.s_axis_b_tdata;
        @(rx.cbr);
        @(rx.cbr);
        @(rx.cbr);
        @(rx.cbr);
        rx.cbr.s_axis_a_tvalid <= '0;
        rx.cbr.s_axis_a_tdata <= '0;
        rx.cbr.s_axis_b_tvalid <= '0;
        rx.cbr.s_axis_b_tdata <= '0;
    endtask: send
    
    class driver_cbs;
        virtual task pre_tx(input driver drv, input adder_cell c);
        endtask: pre_tx
        
        virtual task post_tx(input driver drv, input adder_cell c);
        endtask: post_tx
    endclass: driver_cbs
    
    typedef class monitor_cbs;
    
    class monitor;
        v_add_ifc_tbt tx; //virtual interface with output of dut
        monitor_cbs cbsq[$]; //callback queue
        
        extern function new(input v_add_ifc_tbt tx);
        extern task run();
        extern task receive (output adder_output_cell c);
    endclass: monitor
    
    function monitor::new(input v_add_ifc_tbt tx);
        this.tx = tx;
    endfunction: new
    
    task monitor::run();
        adder_output_cell c;
        tx.cbt.m_axis_result_tready <= 0;
        forever begin
            receive(c);
            foreach(cbsq[i])
                cbsq[i].post_rx(this,c); //post-receive callback
        end
    endtask: run
    
    task monitor::receive(output adder_output_cell c);
        @(tx.cbt);
        tx.cbt.m_axis_result_tready <= 1;
        while(tx.cbt.m_axis_result_tvalid !== 1)
            @(tx.cbt);//loop until output is ready
            
        
        c = new();
        c.m_axis_result_tdata = tx.cbt.m_axis_result_tdata;
        c.display($sformatf("@%0t: Mon%0d: ", $time,0));
    endtask:receive
    
    class monitor_cbs;
        virtual task post_rx(input monitor mon, input adder_output_cell c);
        endtask: post_rx
    endclass:monitor_cbs
    
    class expect_cells;
        adder_output_cell q[$];
        int i_expect, i_actual;
    endclass: expect_cells
    
    class scoreboard;
        env_config cfg;
        expect_cells expect_cell;
        adder_cell cellq[$];
        int i_expect, i_actual;
        
        extern function new(input env_config cfg);
        extern virtual function void wrap_up();
        extern function void save_expected(input adder_cell a_cell);
        extern function void check_actual(input adder_output_cell c);
        extern function void display(input string prefix = "");
        
    endclass: scoreboard
    
    function scoreboard::new(input env_config cfg);
        this.cfg = cfg;
        expect_cell = new();
    endfunction: new
    
    function void scoreboard::wrap_up();
        $display("@%0t: %m %0d expected outputs, %0d actual outputs rcvd",$time,i_expect,i_actual);
        if(expect_cell.q.size()) 
        begin
            $display("@%0t: %0d outputs in SCB at end of test",$time,expect_cell.q.size());
            this.display("Unclaimed: ");
            cfg.num_errors++;
        end
    endfunction: wrap_up
    
    function void scoreboard::save_expected(input adder_cell a_cell);
        adder_output_cell o_cell = a_cell.to_adder_output();
        o_cell.display($sformatf("@%0t: Scb save:", $time, ));
        //o_cell.display();
        expect_cell.q.push_back(o_cell);
        expect_cell.i_expect++;
        i_expect++;
    endfunction: save_expected
    
    function void scoreboard::check_actual(input adder_output_cell c);
        c.display($sformatf("@%0t: Scb check: ", $time));
        if(expect_cell.q.size() == 0)
        begin
            $display("@%0t: ERROR: expected output not found. Scoreboard empty",$time);
            c.display("Not Found: ");
            cfg.num_errors++;
            return;
        end
        
        expect_cell.i_actual++;
        i_actual++;
        
        foreach(expect_cell.q[i])
        begin
            if(expect_cell.q[i].compare(c))
            begin
                $display("@%0t: Match found for output", $time);
                expect_cell.q.delete(i);
                return;
            end
        end
        
        $display("@%0t: ERROR output not found", $time);
        c.display("Not Found: ");
        cfg.num_errors++;
    endfunction: check_actual
    
    function void scoreboard::display(input string prefix = "");
        $display("@%0t: %m so far %0d expected outputs, %0d actual rcvd", $time, i_expect, i_actual);
        foreach(expect_cell.q[i])
        begin
            expect_cell.q[i].display($sformatf("%sScoreboard: ",prefix));
        end
    endfunction: display
    
    class coverage;
        bit [15:0] a;
        bit [15:0] b;
        
        covergroup cg_adder;
            coverpoint a
            {
                bins zero = {0};
                bins decimal = {[15820:16230]};
                bins whole = {[16256:17096]};
            }
            coverpoint b
            {
                bins zero = {0};
                bins decimal = {[15820:16230]};
                bins whole = {[16256:17096]};
            }
        endgroup: cg_adder
        
        function new();
            cg_adder = new();
        endfunction: new 
        
        function void sample(input bit [15:0] a, input bit [15:0] b);
            $display("@%0t: Coverage a=%x. b=%x", $time, a, b);
            this.a = a;
            this.b = b;
            cg_adder.sample();
        endfunction: sample
    endclass: coverage
    
    class scb_driver_cbs extends driver_cbs;
        scoreboard scb;
        
        function new(input scoreboard scb);
            this.scb = scb;
        endfunction: new
        
        virtual task post_tx(input driver drv, input adder_cell c);
            scb.save_expected(c);
        endtask: post_tx
    endclass: scb_driver_cbs
    
    class cov_driver_cbs extends driver_cbs;
        coverage cov;
        
        function new(input coverage cov);
            this.cov = cov;
        endfunction: new
        
        virtual task post_tx(input driver drv, input adder_cell c);
            cov.sample(c.s_axis_a_tdata,c.s_axis_b_tdata);
        endtask: post_tx
    endclass: cov_driver_cbs
    
    class scb_monitor_cbs extends monitor_cbs;
        scoreboard scb;
        
        function new(input scoreboard scb);
            this.scb = scb;
        endfunction: new
        
        virtual task post_rx(input monitor mon, input adder_output_cell c);
            scb.check_actual(c);
        endtask: post_rx
    endclass: scb_monitor_cbs
    
    class environment;
        op_generator gen;
        mailbox gen2drv;
        event drv2gen;
        driver drv;
        monitor mon;
        env_config cfg;
        scoreboard scb;
        coverage cov;
        virtual adder_ifc.TB_rx rx;
        virtual adder_ifc.TB_tx tx;
        
        extern function new(input v_add_ifc_tbr rx, v_add_ifc_tbt tx);
        extern virtual function void gen_cfg();
        extern virtual function void build();
        extern virtual task run();
        extern virtual function void wrap_up();
    endclass: environment
    
    function environment::new(input v_add_ifc_tbr rx, v_add_ifc_tbt tx);
        //construct our environment instance
        this.rx = rx;
        this.tx = tx;
        cfg = new();
        if($test$plusargs("ntb_random_seed"))
        begin
            int seed;
            $value$plusargs("ntb_random_seed=%d", seed);
            $display("Simulation run with random seed=%0d", seed);
        end else 
        begin
            $display("Simulation run with default random seed");
        end
    endfunction: new

    function void environment::gen_cfg();
        `SV_RAND_CHECK(cfg.randomize());
        cfg.display();
    endfunction: gen_cfg
    
    //build the environment objects for this test
    function void environment::build();
        scb = new(cfg);
        cov = new();
        gen2drv = new();
        gen = new(gen2drv,drv2gen,cfg.num_ops);
        drv = new(gen2drv,drv2gen,rx);
        mon = new(this.tx);
        
        //connect scoreboard to drivers and monitors with callbacks
        begin
            scb_driver_cbs sdc = new(scb);
            scb_monitor_cbs smc = new(scb);
            drv.cbsq.push_back(sdc);
            mon.cbsq.push_back(smc);
        end
        
        //connect coverage to driver. ATYPICAL. COVERAGE CAN ALSO BE CONNECTED TO MONITOR
        begin
            cov_driver_cbs cdc = new(cov);
            drv.cbsq.push_back(cdc);
        end
    endfunction: build
    
    task environment::run();
        int num_gen_running;
        num_gen_running = 1;
        fork
            begin //statements inside a fork join block run concurrently. use begin..end statements to control this
                gen.run();
                num_gen_running--;
            end
            drv.run();
        join_none
        fork
            mon.run();
        join_none
        
        fork: timeout_block //used to control with a disable statement
            wait (num_gen_running == 0);
            begin
                repeat(1_000_000) @(tx.cbt);
                $display("@%0t: %m ERROR: Generator timeout ", $time);
                cfg.num_errors++;
            end
        join_any
        
        disable timeout_block;
        
        //wait for data to flow through the device and into monitors and scoreboards
        repeat (1_000) @(tx.cbt);
    endtask:run
    
    //post-run cleanup/reporting
    function void environment::wrap_up();
        $display("@%0t: End of sim, %0d errors, %0d warnings", $time, cfg.num_errors, cfg.num_warnings);
        scb.wrap_up();
    endfunction: wrap_up
    
endpackage: tb_pkg
