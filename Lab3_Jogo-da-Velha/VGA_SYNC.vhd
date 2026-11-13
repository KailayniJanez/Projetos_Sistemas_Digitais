library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Module Generates Video Sync Signals for Video Monitor Interface
-- RGB and Sync outputs tie directly to monitor connector pins

ENTITY VGA_SYNC IS
    PORT(
        clock_50Mhz, red, green, blue : IN STD_LOGIC;

        red_out, green_out, blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        horiz_sync_out, vert_sync_out : OUT STD_LOGIC;

        video_on : OUT STD_LOGIC;
        pixel_clock : OUT STD_LOGIC;

        pixel_row, pixel_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END VGA_SYNC;


ARCHITECTURE a OF VGA_SYNC IS

    SIGNAL horiz_sync, vert_sync, pixel_clock_int : STD_LOGIC;
    SIGNAL video_on_int, video_on_v, video_on_h : STD_LOGIC;
    SIGNAL h_count : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL v_count : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
	 SIGNAL pll_locked : STD_LOGIC;


    -- Horizontal Timing Constants
    CONSTANT H_pixels_across : Natural := 640;
    CONSTANT H_sync_low      : Natural := 664;
    CONSTANT H_sync_high     : Natural := 760;
    CONSTANT H_end_count     : Natural := 800;

    -- Vertical Timing Constants
    CONSTANT V_pixels_down : Natural := 480;
    CONSTANT V_sync_low    : Natural := 491;
    CONSTANT V_sync_high   : Natural := 493;
    CONSTANT V_end_count   : Natural := 525;


    COMPONENT Video_PLL_0002
    PORT (
        refclk   : IN  STD_LOGIC;
        rst      : IN  STD_LOGIC;
        outclk_0 : OUT STD_LOGIC;
        locked   : OUT STD_LOGIC
    );
    END COMPONENT;


BEGIN

    -- PLL used to generate the pixel clock
    video_PLL_inst : Video_PLL_0002
    PORT MAP (
    refclk   => clock_50Mhz,
    rst      => '0',
    outclk_0 => pixel_clock_int,
    locked   => pll_locked
    );


    -- Video is active only when inside the visible area
    video_on_int <= video_on_h AND video_on_v;

    -- Outputs
    pixel_clock <= pixel_clock_int;
    video_on    <= video_on_int;


    PROCESS
    BEGIN

        WAIT UNTIL(pixel_clock_int'EVENT) AND (pixel_clock_int = '1');


        -- Horizontal counter
        IF (h_count = H_end_count - 1) THEN
            h_count <= (OTHERS => '0');
        ELSE
            h_count <= h_count + 1;
        END IF;


        -- Horizontal Sync
        IF (h_count <= H_sync_high) AND (h_count >= H_sync_low) THEN
            horiz_sync <= '0';
        ELSE
            horiz_sync <= '1';
        END IF;


        -- Vertical counter
        IF (v_count = V_end_count - 1) AND (h_count = H_end_count - 1) THEN
            v_count <= (OTHERS => '0');

        ELSIF (h_count = H_end_count - 1) THEN
               v_count <= v_count + 1;
        END IF;


        -- Vertical Sync
        IF (v_count <= V_sync_high) AND (v_count >= V_sync_low) THEN
            vert_sync <= '0';
        ELSE
            vert_sync <= '1';
        END IF;


        -- Horizontal visible area
        IF (h_count < H_pixels_across) THEN
            video_on_h <= '1';
            pixel_column <= h_count;
        ELSE
            video_on_h <= '0';
        END IF;


        -- Vertical visible area
        IF (v_count < V_pixels_down) THEN
            video_on_v <= '1';
            pixel_row <= v_count;
        ELSE
            video_on_v <= '0';
        END IF;


        -- Register sync signals
        horiz_sync_out <= horiz_sync;
        vert_sync_out <= vert_sync;


        -- =====================================================
        -- RGB
        -- =====================================================
        -- When the pixel is inside the visible area:
        -- red   = 11111111 when red = 1
        -- green = 11111111 when green = 1
        -- blue  = 11111111 when blue = 1
        --
        -- Outside the visible area all RGB bits are zero.
        -- =====================================================

        IF video_on_int = '1' THEN

            IF red = '1' THEN
                red_out <= "11111111";
            ELSE
                red_out <= "00000000";
            END IF;


            IF green = '1' THEN
                green_out <= "11111111";
            ELSE
                green_out <= "00000000";
            END IF;


            IF blue = '1' THEN
                blue_out <= "11111111";                             
            ELSE
                blue_out <= "00000000";
            END IF;

        ELSE

            red_out   <= "00000000";
            green_out <= "00000000";
            blue_out  <= "00000000";

        END IF;


    END PROCESS;

END a;                                       

