/*
vinR_assembler.exe   <program.txt> <machine_code.mem> <line to generate>

instcutions in the format of

<instuction> <posible output>, <posible reg1>, <posible reg2>, <posible immeadate>
*there will never really be 4 things after instuction*
// is a coment indicator and everything after it will be ignored

<name>: is a tag for jumps
*/

#include<iostream>
#include<vector>
#include <fstream>
#include <string>
#include <map>

std::vector<std::string> parser(std::string line, char spliter);
std::string reg_to_string(std::string name, int line_num);
std::string num_to_bitstring(int num);

int main(int argc, char* argv[]) {
    std::ifstream program(argv[1]);

    int length = std::stoi(argv[3]); 
    int line_num = 0;
    std::string line;
    std::map< std::string, int > tags;
    std::vector<std::string> machine_code;

    if(program.is_open()){
        while(std::getline(program,line)){
            line_num++;
            std::string opcode = "";
            std::string coment = " //";
            coment.append(line);

            std::vector<std::string> inst = parser(line, ' '); // split line into the difernt words
            if(inst.size()==0||inst[0].substr(0,2)=="//") continue; //if line is empty or a coment continue
            

            if(inst[0][inst[0].length()-1]==':'){ //if it ends in a : then the line muct be a tag so add to tag index
                tags[inst[0].substr(0,inst[0].length()-1)]=machine_code.size();
                continue;
            }


            if(inst[0]=="LUI"||inst[0]=="AUIPC"){ // inst rd, imm
                if(inst[0]=="LUI") opcode = "0110111";
                else opcode = "0010111";
                std::string rd = reg_to_string(inst[1],line_num);
                int imm_loc = 2;
                
                if(inst[2] == ",") imm_loc = 3;
                
                std::string imm = num_to_bitstring(std::stoi(inst[imm_loc]));
                
                for(int i = imm.length(); i<20; i++) imm.insert(0,1,'0');
                

                machine_code.push_back(imm.append(rd).append(opcode).append(coment));
                continue;
            }
            // eventually this will be just one jump instuction for if the offset is more than 20 bits (not now)
            if(inst[0]=="JAL"){ //figure out imm later  // JAL rd, TAG
                opcode = "1101111";
                std::string rd = reg_to_string(inst[1],line_num);
                int tag_loc = 2;
                if(inst[2][0] == ',') tag_loc = 3;
                std::string tag = "J ";

                machine_code.push_back(tag.append(inst[tag_loc].append(" ").append(rd).append(opcode)).append(coment));
                continue;
            }
            if(inst[0]=="JALR"){ // JALR rd, rs1, imm //for now this womt use tags 
                opcode = "1100111";

                std::string rd = reg_to_string(inst[1],line_num);
                int off = 2;
                if(inst[off] == ",") off++;
                std::string rs1 = reg_to_string(inst[off],line_num);
                off++;
                if(inst[off] == ",") off++;
                std::string imm = num_to_bitstring(std::stoi(inst[off]));
                for(int i = imm.length(); i<12; i++) imm.insert(0,1,'0');
                std::string spacer = "000";

                machine_code.push_back(imm.append(rs1).append(spacer).append(rd).append(opcode).append(coment));
                continue;
            }
            if(inst[0]=="BEQ"||inst[0]=="BNE"||inst[0]=="BLT"||inst[0]=="BGE"||inst[0]=="BLTU"||inst[0]=="BGEU"){  //inst rs1, rs2, tag
                opcode = "1100011";

                std::string rs1 = reg_to_string(inst[1],line_num);
                int off = 2;
                if(inst[off] == ",") off++;
                std::string rs2 = reg_to_string(inst[off],line_num);
                off++;
                if(inst[off] == ",") off++;
                std::string tag = "B ";
                tag.append(inst[off]);
                std::string fuc3 = "";
                if(inst[0].length()==4){
                    if(inst[0][1]=='L') fuc3 = "110";
                    else fuc3 = "111";
                }
                else {
                    if(inst[0][1]=='E') fuc3 = "000";
                    else if(inst[0][1]=='N') fuc3 = "001";
                    else if(inst[0][1]=='L') fuc3 = "100";
                    else fuc3 = "101";
                }

                machine_code.push_back(tag.append(" ").append(rs2).append(rs1).append(fuc3).append(" ").append(opcode).append(coment));
                continue;
            }
            if(inst[0]=="LB"||inst[0]=="LH"||inst[0]=="LW"||inst[0]=="LBU"||inst[0]=="LHU"){ // inst rd, rs1, imm
                opcode = "0000011";
                std::string rd = reg_to_string(inst[1],line_num);
                int off = 2;
                if(inst[off] == ",") off++;
                std::string rs1 = reg_to_string(inst[off],line_num);
                off++;
                if(inst[off] == ",") off++;
                std::string imm = num_to_bitstring(std::stoi(inst[off]));
                for(int i = imm.length(); i<12; i++) imm.insert(0,1,'0');

                std::string fuc3 = "";
                if(inst[0].length()==3){
                    if(inst[0][1]=='B') fuc3 = "100";
                    else fuc3 = "101";
                }
                else {
                    if(inst[0][1]=='B') fuc3 = "000";
                    else if(inst[0][1]=='H') fuc3 = "001";
                    else fuc3 = "010";
                }
                
                machine_code.push_back(imm.append(rs1).append(fuc3).append(rd).append(opcode).append(coment));
                continue;
            }
            if(inst[0]=="SB"||inst[0]=="SH"||inst[0]=="SW"){ // inst rs1, rs2, imm
                opcode = "0100011";
                std::string rs1 = reg_to_string(inst[1],line_num);
                int off = 2;
                if(inst[off] == ",") off++;
                std::string rs2 = reg_to_string(inst[off],line_num);
                off++;
                if(inst[off] == ",") off++;
                std::string imm = num_to_bitstring(std::stoi(inst[off]));
                for(int i = imm.length(); i<12; i++) imm.insert(0,1,'0');

                std::string fuc3 = "";
                if(inst[0][1]=='B') fuc3 = "000";
                else if(inst[0][1]=='H') fuc3 = "001";
                else fuc3 = "010";


                machine_code.push_back(imm.substr(0,7).append(rs2).append(rs1).append(fuc3).append(imm.substr(7,5)).append(opcode).append(coment));

                continue;
            }
            if(inst[0]=="ADDI"||inst[0]=="SLTI"||inst[0]=="SLTIU"||inst[0]=="XORI"||inst[0]=="ORI"||inst[0]=="ANDI"){ // inst rd, rs1, imm
                opcode = "0010011";

                std::string rd = reg_to_string(inst[1],line_num);
                int off = 2;
                if(inst[off] == ",") off++;
                std::string rs1 = reg_to_string(inst[off],line_num);
                off++;
                if(inst[off] == ",") off++;
                std::string imm = num_to_bitstring(std::stoi(inst[off]));
                for(int i = imm.length(); i<12; i++) imm.insert(0,1,'0');

                std::string fuc3 = "";
                if(inst[0].length()==5) fuc3 = "011";
                else if(inst[0].length()==3) fuc3 = "110";
                else {
                    if(inst[0][1]=='D') fuc3 = "000";
                    else if(inst[0][1]=='L') fuc3 = "010";
                    else if(inst[0][1]=='O') fuc3 = "100";
                    else fuc3 = "111";
                }

                machine_code.push_back(imm.append(rs1).append(fuc3).append(rd).append(opcode).append(coment));
                continue;
            }
            if(inst[0]=="SLLI"||inst[0]=="SRLI"||inst[0]=="SRAI"){ // inst rd, rs1, imm
                opcode = "0010011";

                std::string rd = reg_to_string(inst[1],line_num);
                int off = 2;
                if(inst[off] == ",") off++;
                std::string rs1 = reg_to_string(inst[off],line_num);
                off++;
                if(inst[off] == ",") off++;
                std::string imm = num_to_bitstring(std::stoi(inst[off]));
                for(int i = imm.length(); i<5; i++) imm.insert(0,1,'0');

                std::string fuc7, fuc3;

                if(inst[0][2]=='A') fuc7 = "0100000";
                else fuc7 = "0000000";

                if(inst[0][1]=='L') fuc3 = "001";
                else fuc3 = "101";

                machine_code.push_back(fuc7.append(imm).append(rs1).append(fuc3).append(rd).append(opcode).append(coment));
                continue;
            }
            if(inst[0]=="ADD"||inst[0]=="SUB"||inst[0]=="SLL"||inst[0]=="SLT"||inst[0]=="SLTU"||inst[0]=="XOR"||inst[0]=="SRL"||inst[0]=="SRA"||inst[0]=="OR"||inst[0]=="AND"){
                opcode = "0110011"; //inst rd, rs1, rs2

                std::string rd = reg_to_string(inst[1],line_num);
                int off = 2;
                if(inst[off] == ",") off++;
                std::string rs1 = reg_to_string(inst[off],line_num);
                off++;
                if(inst[off] == ",") off++;
                std::string rs2 = reg_to_string(inst[off],line_num);

                std::string fuc7, fuc3;
                if(inst[0].length()==3&&(inst[0][2]=='B'||inst[0][2]=='A')) fuc7 = "0100000";
                else fuc7 = "0000000";

                if(inst[0].length()==4) fuc3 = "011"; 
                else if(inst[0].length()==2) fuc3 = "110"; 
                else if(inst[0]=="ADD"||inst[0]=="SUB") fuc3 = "000"; 
                else if(inst[0]=="SLL") fuc3 = "001"; 
                else if(inst[0]=="SLT") fuc3 = "010"; 
                else if(inst[0]=="XOR") fuc3 = "100"; 
                else if(inst[0][1]=='R') fuc3 = "101"; 
                else if(inst[0]=="AND") fuc3 = "111"; 

                machine_code.push_back(fuc7.append(rs2).append(rs1).append(fuc3).append(rd).append(opcode).append(coment));
                continue;
            }
            if(inst[0]=="FENCE"){ //no-op rn
                std::string bits = "00000000000000000000000000001111";

                machine_code.push_back(bits.append(coment));
                continue;
            }
            if(inst[0]=="FENCE.TSO"){ //implentting because always the same so while not but all no-op or break from noe on
                std::string bits = "10000011001100000000000000001111";

                machine_code.push_back(bits.append(coment));
                continue;
            }
            if(inst[0]=="PAUSE"){
                std::string bits = "00000001000000000000000000001111";

                machine_code.push_back(bits.append(coment));
                continue;
            }
            if(inst[0]=="ECALL"){ //halts for afetr here
                std::string bits = "00000000000000000000000001110011";

                machine_code.push_back(bits.append(coment));
                continue;
            }
            if(inst[0]=="EBREAK"){
                std::string bits = "00000000000100000000000001110011";

                machine_code.push_back(bits.append(coment));
                continue;
            }

            std::cerr<< "ERROR: invalad instuction on line: "<<line_num;
        }
    }
    else std::cerr << "ERROR: file not opended, makre surre the comand is in the format of: vinR_assembler.exe   <program.txt> <machine_code.mem> <line to generate>";
    program.close();

    std::ofstream complied(argv[2]);//opening the program and the output file

    if(4*machine_code.size()>length) std::cerr<<"WARNING: code size is larger than length alocated (will continue but will be longer)";

    for(int i = 0; i<machine_code.size();i++){
        if(machine_code[i][0]=='J') { //we have a jump to tag
            std::vector<std::string> split = parser(machine_code[i], ' ');
            int to_line_num = tags[split[1]];
            if(to_line_num == -1) std::cerr<<"ERROR: tag: "<<split[1]<<" does not exist";
            int jump_length = 4*(to_line_num-i);

            std::string imm = num_to_bitstring(jump_length/2);
            if(jump_length<0) for(int i = imm.length(); i<12; i++) imm.insert(0,1,'1');
            else for(int i = imm.length(); i<12; i++) imm.insert(0,1,'0');
            std::string re_imm = imm.substr(0,1);
            re_imm.append(imm.substr(10,10));
            re_imm.append(imm.substr(9,1));
            re_imm.append(imm.substr(1,8));

            std::string final = re_imm.append(split[2]);
            complied<<final.substr(24,8);

            for(int j=3; j<split.size();j++) complied<<" "<<split[j];
            complied<<std::endl;
            complied<<final.substr(16,8)<<std::endl;
            complied<<final.substr(8,8)<<std::endl;
            complied<<final.substr(0,8)<<std::endl;
            
            
            
        }
        else if(machine_code[i][0]=='B') { //we have a if branch tag
            std::vector<std::string> split = parser(machine_code[i], ' ');
            int to_line_num = tags[split[1]];
            if(to_line_num == -1) std::cerr<<"ERROR: tag: "<<split[1]<<" does not exist";
            int jump_length = 4*(to_line_num-i);

            std::string imm = num_to_bitstring(jump_length/2);
            if(jump_length<0) for(int i = imm.length(); i<12; i++) imm.insert(0,1,'1');
            else for(int i = imm.length(); i<12; i++) imm.insert(0,1,'0');
            std::string re_up_imm = imm.substr(0,1);
            re_up_imm.append(imm.substr(2,6));
            std::string re_down_imm = imm.substr(8,4);
            re_down_imm.append(imm.substr(1,1));
            std::string final = re_up_imm.append(split[2]).append(re_down_imm).append(split[3]);
            complied<<final.substr(24,8);

            for(int j=4; j<split.size();j++) complied<<" "<<split[j];
            complied<<std::endl;
            complied<<final.substr(16,8)<<std::endl;
            complied<<final.substr(8,8)<<std::endl;
            complied<<final.substr(0,8)<<std::endl;
            
        }
        else {
            complied<<machine_code[i].substr(24,machine_code[i].length()-24)<<std::endl;
            complied<<machine_code[i].substr(16,8)<<std::endl;
            complied<<machine_code[i].substr(8,8)<<std::endl;
            complied<<machine_code[i].substr(0,8)<<std::endl;
            
        }
    }
    for(int i = 0;i<length-4*machine_code.size(); i++){
        complied<<"00000000"<<std::endl;
    }

}


std::vector<std::string> parser(std::string line, char spliter){ //parses lines on splitter
    std::string temp = "";
    std::vector<std::string> parsed;
    for(char c : line){
        if(c==spliter){
            if(temp.length() == 0) continue;
            parsed.push_back(temp);
            temp = "";
        }
        else{
            temp.push_back(c);
        }
    }
    if(temp.length() != 0) parsed.push_back(temp);
    return parsed;
}

std::string reg_to_string(std::string name, int line_num){ //input regester name, output bitstring
    if(name[0]!='x') std::cerr<<"ERROR: indalid register name on line " << line_num;
    std::string num(1,name[1]);
    if(std::isdigit(name[2])) num.push_back(name[2]);
    int reg = std::stoi(num);
    std::string out = num_to_bitstring(reg);
    for(int i = out.length(); i<5; i++)out.insert(0,1,'0');
    return out;
}


std::string num_to_bitstring(int num){ //turns ints into bitstings
    std::string out = "";
    while(num!=0){out.insert(0,1,num%2 ? '1':'0'); num/=2;}
    return out;
}