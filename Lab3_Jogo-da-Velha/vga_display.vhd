
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY vga_display IS
    PORT (
        clk        : IN  STD_LOGIC;
        h_counter  : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        v_counter  : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        tabuleiro  : IN  STD_LOGIC_VECTOR(17 DOWNTO 0);

        vga_r      : OUT STD_LOGIC;
        vga_g      : OUT STD_LOGIC;
        vga_b      : OUT STD_LOGIC
    );
END vga_display;

ARCHITECTURE rtl OF vga_display IS
    CONSTANT TELA_LARGURA : INTEGER := 640;
    CONSTANT TELA_ALTURA  : INTEGER := 480;

    CONSTANT X_INICIO : INTEGER := 140;
    CONSTANT Y_INICIO : INTEGER := 60;
    CONSTANT TAM_CEL  : INTEGER := 120;
    CONSTANT ESP_LINHA : INTEGER := 5;

    CONSTANT TAM_MARCA : INTEGER := 60;
    CONSTANT ESP_MARCA : INTEGER := 7;

    SIGNAL x : INTEGER RANGE 0 TO 1023;
    SIGNAL y : INTEGER RANGE 0 TO 1023;
BEGIN

    x <= TO_INTEGER(UNSIGNED(h_counter));
    y <= TO_INTEGER(UNSIGNED(v_counter));

    PROCESS(clk)
        VARIABLE px, py : INTEGER;
        VARIABLE celula : INTEGER;
        VARIABLE dentro_tabuleiro : BOOLEAN;
        VARIABLE desenhar_linha : BOOLEAN;
        VARIABLE desenhar_x : BOOLEAN;
        VARIABLE desenhar_o : BOOLEAN;
        VARIABLE dx, dy : INTEGER;
        VARIABLE indice : INTEGER;
    BEGIN
        IF rising_edge(clk) THEN
            px := x;
            py := y;

            -- Fundo preto
            vga_r <= '0';
            vga_g <= '0';
            vga_b <= '0';

            -- Linhas brancas do tabuleiro
            desenhar_linha := FALSE;

            IF (px >= X_INICIO) AND
               (px <= X_INICIO + 3*TAM_CEL) AND
               (py >= Y_INICIO) AND
               (py <= Y_INICIO + 3*TAM_CEL) THEN

                IF (ABS(px - (X_INICIO + TAM_CEL)) <= ESP_LINHA) OR
                   (ABS(px - (X_INICIO + 2*TAM_CEL)) <= ESP_LINHA) OR
                   (ABS(py - (Y_INICIO + TAM_CEL)) <= ESP_LINHA) OR
                   (ABS(py - (Y_INICIO + 2*TAM_CEL)) <= ESP_LINHA) THEN
                    desenhar_linha := TRUE;
                END IF;
            END IF;

            IF desenhar_linha THEN
                vga_r <= '1';
                vga_g <= '1';
                vga_b <= '1';
            ELSE
                -- Identifica a célula correspondente ao pixel
                IF (px >= X_INICIO) AND
                   (px < X_INICIO + 3*TAM_CEL) AND
                   (py >= Y_INICIO) AND
                   (py < Y_INICIO + 3*TAM_CEL) THEN

                    celula :=
                        ((py - Y_INICIO) / TAM_CEL) * 3 +
                        ((px - X_INICIO) / TAM_CEL);

                    indice := celula * 2;

                    dx := (px - X_INICIO) MOD TAM_CEL;
                    dy := (py - Y_INICIO) MOD TAM_CEL;

                    desenhar_x := FALSE;
                    desenhar_o := FALSE;

                    -- X: valor 01; O: valor 10
                    IF (ABS(dx - dy) <= ESP_MARCA) OR
                       (ABS((TAM_CEL - 1 - dx) - dy) <= ESP_MARCA) THEN
                        IF tabuleiro(indice + 1 DOWNTO indice) = "01" THEN
                            desenhar_x := TRUE;
                        END IF;
                    END IF;

                    -- Desenha o círculo do O
                    IF tabuleiro(indice + 1 DOWNTO indice) = "10" THEN
                        IF ABS(
                            (dx - (TAM_CEL / 2)) *
                            (dx - (TAM_CEL / 2)) +
                            (dy - (TAM_CEL / 2)) *
                            (dy - (TAM_CEL / 2)) -
                            (TAM_MARCA / 2) * (TAM_MARCA / 2)
                        ) <= TAM_MARCA * ESP_MARCA THEN
                            desenhar_o := TRUE;
                        END IF;
                    END IF;

                    IF desenhar_x OR desenhar_o THEN
                        vga_r <= '1';
                        vga_g <= '1';
                        vga_b <= '1';
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END rtl;