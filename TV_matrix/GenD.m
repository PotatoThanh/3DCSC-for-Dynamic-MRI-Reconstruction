function [D, Dt] = GenD(Nx,Ny,Nt)
% GEND - AUXILIARY FUNCTION
%  Generate matrices D and Dt (D transpose) for the processing of a
%  sequence with dimensions [Nx,Ny,Nt]. These matrices act as row operators
%  calculating the TV in time, such that D*x outputs the column vector of
%  the first-order temporal gradient of sequence x. These matrices can be
%  expensive to generate, which is why it is recommended that they are
%  computed offline, saved and loaded for processing as required.
%
%  Inputs:
%   [Nx,Ny,Nt] : Dimensions of sequence to reconstruct.
%
%  Outputs:
%   [D, Dt] : Matrix operators for computing the TV in time on a vectorised
%             sequence (D) and its transpose (Dt).


%  Jose Caballero
%  Biomedical and Image Analysis Group
%  Department of Computing
%  Imperial College London, London SW7 2AZ, UK
%  jose.caballero06@imperial.ac.uk
%
%  October 2012


D = sparse(Nx*Ny*Nt,Nx*Ny*Nt);
Dt = sparse(Nx*Ny*Nt,Nx*Ny*Nt);


for i = 0:Nx*Ny*(Nt-1)-1;
    i
index_neg = 1+i*(1+Nx*Ny*Nt);
index_pos = (Nx*Ny*(Nt)*Nx*Ny+1) + i*(1+Nx*Ny*(Nt));
index_pos_t = Nx*Ny+1 + i*(1+Nx*Ny*Nt);
D(index_neg) = int8(-1);
D(index_pos) = int8(1);
Dt(index_neg) = int8(-1);
Dt(index_pos_t) = int8(1);
end

for i = 0:Nx*Ny-1
    i
    index_pos2 = 1+Nx*Ny*(Nt-1)+i*(1+Nx*Ny*(Nt));
    index_pos_t2 = Nx*Ny*(Nt-1)*Nx*Ny*Nt+1 + i*(1+Nx*Ny*(Nt));
    index_neg2 = Nx*Ny*Nt*(Nx)*(Ny)*(Nt-1)+1+Nx*Ny*(Nt-1)+i*(1+Nx*Ny*(Nt));
    index_neg_t2 = Nx*Ny*(Nt-1) + Nx*Ny*(Nt-1)*Nx*Ny*Nt+1 + i*(1+Nx*Ny*(Nt));
    
    D(index_pos2) = int8(1);
    D(index_neg2) = int8(-1);
    Dt(index_pos_t2) = int8(1);  
    Dt(index_neg_t2) = int8(-1);
end

end