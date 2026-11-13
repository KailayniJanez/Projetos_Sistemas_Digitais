// ============================================================
// PicTacToegf - Jogo da Velha (parte sem VGA)
// Implementacao para Quartus Prime / Verilog HDL
//
// Cada casa do tabuleiro usa 2 bits:
//   00 = vazia
//   01 = jogador 1
//   10 = jogador 2
//
// Casas:
//   0 1 2
//   3 4 5
//   6 7 8
// ============================================================

module PicTacToegf (
    input        clk,
    input        reset,
    input        player,
    input  [3:0] position,

    output reg [17:0] board,
    output reg  [8:0] leds,
    output reg        win1,
    output reg        win2,
    output reg        draw,
    output reg        game_over
);

    reg [1:0] cell0, cell1, cell2;
    reg [1:0] cell3, cell4, cell5;
    reg [1:0] cell6, cell7, cell8;

    // --------------------------------------------------------
    // Atualizacao do tabuleiro
    // player = 0 -> jogador 1
    // player = 1 -> jogador 2
    // --------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            board <= 18'b0;
        end
        else if (!game_over && position <= 4'd8) begin
            case (position)
                4'd0: if (board[1:0]   == 2'b00)
                            board[1:0]   <= player ? 2'b10 : 2'b01;

                4'd1: if (board[3:2]   == 2'b00)
                            board[3:2]   <= player ? 2'b10 : 2'b01;

                4'd2: if (board[5:4]   == 2'b00)
                            board[5:4]   <= player ? 2'b10 : 2'b01;

                4'd3: if (board[7:6]   == 2'b00)
                            board[7:6]   <= player ? 2'b10 : 2'b01;

                4'd4: if (board[9:8]   == 2'b00)
                            board[9:8]   <= player ? 2'b10 : 2'b01;

                4'd5: if (board[11:10] == 2'b00)
                            board[11:10] <= player ? 2'b10 : 2'b01;

                4'd6: if (board[13:12] == 2'b00)
                            board[13:12] <= player ? 2'b10 : 2'b01;

                4'd7: if (board[15:14] == 2'b00)
                            board[15:14] <= player ? 2'b10 : 2'b01;

                4'd8: if (board[17:16] == 2'b00)
                            board[17:16] <= player ? 2'b10 : 2'b01;

                default: ;
            endcase
        end
    end

    // --------------------------------------------------------
    // Separacao das 9 casas
    // --------------------------------------------------------
    always @(*) begin
        cell0 = board[1:0];
        cell1 = board[3:2];
        cell2 = board[5:4];

        cell3 = board[7:6];
        cell4 = board[9:8];
        cell5 = board[11:10];

        cell6 = board[13:12];
        cell7 = board[15:14];
        cell8 = board[17:16];
    end

    // --------------------------------------------------------
    // Verificacao de vitoria, empate e fim de jogo
    // --------------------------------------------------------
    always @(*) begin

        // Jogador 1: 01
        win1 =
            ((cell0 == 2'b01) && (cell1 == 2'b01) && (cell2 == 2'b01)) ||
            ((cell3 == 2'b01) && (cell4 == 2'b01) && (cell5 == 2'b01)) ||
            ((cell6 == 2'b01) && (cell7 == 2'b01) && (cell8 == 2'b01)) ||
            ((cell0 == 2'b01) && (cell3 == 2'b01) && (cell6 == 2'b01)) ||
            ((cell1 == 2'b01) && (cell4 == 2'b01) && (cell7 == 2'b01)) ||
            ((cell2 == 2'b01) && (cell5 == 2'b01) && (cell8 == 2'b01)) ||
            ((cell0 == 2'b01) && (cell4 == 2'b01) && (cell8 == 2'b01)) ||
            ((cell2 == 2'b01) && (cell4 == 2'b01) && (cell6 == 2'b01));

        // Jogador 2: 10
        win2 =
            ((cell0 == 2'b10) && (cell1 == 2'b10) && (cell2 == 2'b10)) ||
            ((cell3 == 2'b10) && (cell4 == 2'b10) && (cell5 == 2'b10)) ||
            ((cell6 == 2'b10) && (cell7 == 2'b10) && (cell8 == 2'b10)) ||
            ((cell0 == 2'b10) && (cell3 == 2'b10) && (cell6 == 2'b10)) ||
            ((cell1 == 2'b10) && (cell4 == 2'b10) && (cell7 == 2'b10)) ||
            ((cell2 == 2'b10) && (cell5 == 2'b10) && (cell8 == 2'b10)) ||
            ((cell0 == 2'b10) && (cell4 == 2'b10) && (cell8 == 2'b10)) ||
            ((cell2 == 2'b10) && (cell4 == 2'b10) && (cell6 == 2'b10));

        // Empate: nenhuma casa vazia e ninguem venceu
        draw =
            (cell0 != 2'b00) &&
            (cell1 != 2'b00) &&
            (cell2 != 2'b00) &&
            (cell3 != 2'b00) &&
            (cell4 != 2'b00) &&
            (cell5 != 2'b00) &&
            (cell6 != 2'b00) &&
            (cell7 != 2'b00) &&
            (cell8 != 2'b00) &&
            !win1 && !win2;

        game_over = win1 || win2 || draw;

        // Um LED acende quando a casa esta ocupada.
        leds[0] = (cell0 != 2'b00);
        leds[1] = (cell1 != 2'b00);
        leds[2] = (cell2 != 2'b00);
        leds[3] = (cell3 != 2'b00);
        leds[4] = (cell4 != 2'b00);
        leds[5] = (cell5 != 2'b00);
        leds[6] = (cell6 != 2'b00);
        leds[7] = (cell7 != 2'b00);
        leds[8] = (cell8 != 2'b00);
    end

endmodule
