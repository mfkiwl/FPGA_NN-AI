module nn_interface(CLOCK_50, KEY, PS2_CLK, PS2_DAT, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N,
    VGA_SYNC_N, VGA_R, VGA_G, VGA_B, LEDR, IMG);
    input CLOCK_50;
    input[3:0] KEY;
    inout PS2_CLK, PS2_DAT;
    output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    output[9:0]	VGA_R, VGA_G, VGA_B;
    output[9:0] LEDR;
    output[195:0] IMG;
    wire count_reset, usererase;
    wire draw, erase, slow_clock;
    wire[8:0] x, y;
    wire[14:0] color;
    reg[8:0] mousex, mousey, drawx, drawy;
    reg leftclick, rightclick;
    wire[195:0] wooyer;
    reg[3:0] count;

    assign count_reset = KEY[3];
    assign usererase = !KEY[0];

    vga_adapter VGA(count_reset, CLOCK_50, color, x, y, draw, VGA_R, VGA_G,
        VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
    defparam VGA.RESOLUTION = "320x240";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 5;
    defparam VGA.BACKGROUND_IMAGE = "background.mif";

    mouse_tracker mouse(CLOCK_50, count_reset, 1'b1, PS2_CLK, PS2_DAT,
        mousex, mousey, rightclick, leftclick, count);
    defparam mouse.XMIN = 9'd89;
    defparam mouse.XMAX = 9'd229 - 9'd10;
    defparam mouse.YMIN = 9'd33;
    defparam mouse.YMAX = 9'd229 - 9'd10;
    defparam mouse.YSTART = 9'd126;
    defparam mouse.XSTART = 9'd160;

    rate_divider slowclock(1'b1, CLOCK_50, count_reset, 28'd100, slow_clock);

    mod mod1(CLOCK_50, 5'd10, mousex, drawx);
    mod mod2(CLOCK_50, 5'd14, mousey - 6, drawy);

    io_datapath datapath(slow_clock, count_reset, draw, erase, drawx, drawy + 6, x, y);

    io_control control(slow_clock, usererase, leftclick, draw, erase, color);

    image_decoder decoder(CLOCK_50, usererase, drawx + 1, drawy + 7, leftclick, wooyer);

    assign LEDR[9:0] = wooyer[9:0];
    assign IMG = wooyer;
endmodule
