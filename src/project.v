`default_nettype none

module tt_um_AlephNaNsea_space_time_waves_and_filaments(
    input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,   // VGA PMOD Outputs
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

    // --- VGA Sync Engine ---
    reg [9:0] h_count;
    reg [9:0] v_count;

    always @(posedge clk) begin
        if (!rst_n) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == 799) begin
                h_count <= 0;
                if (v_count == 524) v_count <= 0;
                else               v_count <= v_count + 1;
            end else h_count <= h_count + 1;
        end
    end

    wire video_active = (h_count < 640) && (v_count < 480);
    wire hsync = ~(h_count >= 656 && h_count < 752); 
    wire vsync = ~(v_count >= 490 && v_count < 492); 

    // --- Animation Timers ---
    reg [21:0] frame_timer;
    always @(posedge clk) begin
        if (!rst_n) frame_timer <= 0;
        else if (h_count == 799 && v_count == 524) frame_timer <= frame_timer + 1;
    end

    // Increments by 4 every frame for smooth 60fps flow
    wire [9:0] speed_x4 = frame_timer[9:0] << 2; 

    // =========================================================
    // =   Shared Geometry: Center Origin & Octagon Math       =
    // =========================================================
    wire [9:0] cx = (h_count > 320) ? (h_count - 320) : (320 - h_count);
    wire [9:0] cy = (v_count > 240) ? (v_count - 240) : (240 - v_count);

    wire [9:0] max_d = (cx > cy) ? cx : cy;
    wire [9:0] min_d = (cx > cy) ? cy : cx;
    wire [9:0] oct_dist = max_d + (min_d >> 1); 

    // =========================================================
    // =   Engine 0: The Cosmic Web "Black Hole" (DEFAULT)     =
    // =========================================================
    wire [9:0] m_rot1_x = cx + (cy >> 1);
    wire [9:0] m_rot1_y = (cy > (cx >> 1)) ? (cy - (cx >> 1)) : ((cx >> 1) - cy);
    wire [9:0] max_m1 = (m_rot1_x > m_rot1_y) ? m_rot1_x : m_rot1_y;
    wire [9:0] min_m1 = (m_rot1_x > m_rot1_y) ? m_rot1_y : m_rot1_x;
    wire [9:0] oct_m1 = max_m1 + (min_m1 >> 1);

    wire [9:0] m_rot2_x = (cx > (cy >> 1)) ? (cx - (cy >> 1)) : ((cy >> 1) - cx);
    wire [9:0] m_rot2_y = cy + (cx >> 1);
    wire [9:0] max_m2 = (m_rot2_x > m_rot2_y) ? m_rot2_x : m_rot2_y;
    wire [9:0] min_m2 = (m_rot2_x > m_rot2_y) ? m_rot2_y : m_rot2_x;
    wire [9:0] oct_m2 = max_m2 + (min_m2 >> 1);

    wire [9:0] cosmic_val = oct_dist ^ oct_m1 ^ oct_m2;
    wire [9:0] cosmic_anim = cosmic_val + speed_x4; 

    wire is_hot_node = (cosmic_anim[6:0] < 6);   
    wire is_filament = (cosmic_anim[6:0] < 18);  
    wire is_glow     = (cosmic_anim[6:0] < 36);  

    // =========================================================
    // =   Engine 1: Centered Tunnel (ui_in[2])                =
    // =========================================================
    wire [9:0] XOR_tunnel = (cx ^ cy) - speed_x4; 

    // =========================================================
    // =   Engine 2: Red, White, & Blue Spider Web (ui_in[1])  =
    // =========================================================
    wire [9:0] diff_cx_cy  = (cx > cy) ? (cx - cy) : (cy - cx);
    wire [9:0] diff_cx_hcy = (cx > (cy>>1)) ? (cx - (cy>>1)) : ((cy>>1) - cx);
    wire [9:0] diff_cy_hcx = (cy > (cx>>1)) ? (cy - (cx>>1)) : ((cx>>1) - cy);

    wire spoke_v = (cx < 2);
    wire spoke_h = (cy < 2);
    wire spoke_d1 = (diff_cx_cy < 3);
    wire spoke_d2 = (diff_cx_hcy < 2);
    wire spoke_d3 = (diff_cy_hcx < 2);
    wire is_spoke = spoke_v | spoke_h | spoke_d1 | spoke_d2 | spoke_d3;

    wire [9:0] web_ring_pos = oct_dist - speed_x4; 
    wire is_ring = (web_ring_pos[5:0] < 3); 
    wire web_bg_band = web_ring_pos[6];     

    wire show_web = is_spoke | is_ring;

    // =========================================================
    // =   Engine 3: Rolling Ocean Waves (ui_in[0])            =
    // =========================================================
    // Create a right-moving pseudo-sine (triangle) wave 
    wire [8:0] flow1 = cx + speed_x4;
    wire [7:0] triangle1 = flow1[7:0] ^ {8{flow1[8]}}; // 0 to 127
    
    // Create a left-moving pseudo-sine wave going a bit slower
    wire [8:0] flow2 = cx - (speed_x4 >> 1); 
    wire [7:0] triangle2 = flow2[7:0] ^ {8{flow2[8]}}; // 0 to 127
    
    // Combine the X-distortions with the Y-coordinate to create the wave height
    wire [9:0] wave_height = cy + (triangle1 >> 1) + (triangle2 >> 1);
    
    // Scroll the whole surface downward
    wire [9:0] wave_anim = wave_height - speed_x4;
    
    // Assign sea colors: cyan and blue with tiny white foam crests
    wire [1:0] gen_R = (wave_anim[6:5] == 2'b11) ? 2'b01 : 2'b00; 
    wire [1:0] gen_G = wave_anim[7:6];
    wire [1:0] gen_B = 2'b11; // Solid blue base layer

    // =========================================================
    // =                 Main Output Multiplexer               =
    // =========================================================
    reg [1:0] R, G, B;
    
    always @(*) begin
        // Default assignment to prevent latches
        R = 2'b00; G = 2'b00; B = 2'b00;

        if (!video_active) begin
            R = 2'b00; G = 2'b00; B = 2'b00;
        end else if (ui_in[2]) begin
            // PRIORITY MODE (ui_in[2]): Centered Tunnel 
            R = XOR_tunnel[5:4]; 
            G = XOR_tunnel[6:5]; 
            B = XOR_tunnel[7:6];
        end else if (ui_in[1]) begin
            // MODE (ui_in[1]): Red, White, & Blue Spiderweb
            if (show_web) begin
                R = 2'b11; G = 2'b11; B = 2'b11; // Crisp White threads
            end else if (web_bg_band) begin
                R = 2'b11; G = 2'b00; B = 2'b00; // Solid Red background bands
            end else begin
                R = 2'b00; G = 2'b00; B = 2'b11; // Solid Blue background bands
            end
        end else if (ui_in[0]) begin
            // MODE (ui_in[0]): Rolling Ocean Waves
            R = gen_R;
            G = gen_G;
            B = gen_B;
        end else begin
            // DEFAULT MODE (All buttons off): Cosmic Black Hole
            if (is_hot_node) begin
                R = 2'b11; G = 2'b10; B = 2'b00; 
            end else if (is_filament) begin
                R = 2'b01; G = 2'b00; B = 2'b11; 
            end else if (is_glow) begin
                R = 2'b00; G = 2'b00; B = 2'b01; 
            end else begin
                R = 2'b00; G = 2'b00; B = 2'b00; 
            end
        end
    end

    // --- TinyVGA PMOD Explicit Output Mapping ---
    assign uo_out[7] = hsync;
    assign uo_out[6] = B[0];
    assign uo_out[5] = G[0];
    assign uo_out[4] = R[0];
    assign uo_out[3] = vsync;
    assign uo_out[2] = B[1];
    assign uo_out[1] = G[1];
    assign uo_out[0] = R[1]; 

    // Unused pins
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
    wire _unused = &{ena, ui_in[7:3], uio_in}; 

endmodule
