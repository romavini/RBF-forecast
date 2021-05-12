function [TrocasePalpites]=CompraeVenda(n1, j1, Y, Dtest)
Valor_Local=50000;
Valor_Extng=0;
for i=n1:size(Y,1)
	for j=j1:size(Y,2)
								%BP;MP;BT;MT;VLocal;VExg;Lucro
		TrocasePalpites{i,j}=[0 0 0 0 Valor_Local Valor_Extng 0];
		for k=1:(size(Y{i,j},1)-1)

			%%Compra Extng
			if Y{i,j}(k+1,:)>Dtest{i,j}(k,:)
				if Dtest{i,j}(k+1,:) > Dtest{i,j}(k,:)
					TrocasePalpites{i,j}(1,1)=TrocasePalpites{i,j}(1,1)+1;
					if TrocasePalpites{i,j}(1,5)>0
						TrocasePalpites{i,j}(1,3)=TrocasePalpites{i,j}(1,3)+1;
						TrocasePalpites{i,j}(1,6)=TrocasePalpites{i,j}(1,5)/Dtest{i,j}(k,:);
						TrocasePalpites{i,j}(1,5)=0;
					end
				else
					TrocasePalpites{i,j}(1,2)=TrocasePalpites{i,j}(1,2)+1;
					if TrocasePalpites{i,j}(1,5)>0
						TrocasePalpites{i,j}(1,4)=TrocasePalpites{i,j}(1,4)+1;
						TrocasePalpites{i,j}(1,6)=TrocasePalpites{i,j}(1,5)/Dtest{i,j}(k,:);
						TrocasePalpites{i,j}(1,5)=0;
					end					
				end
			%%Venda Extng
			elseif Y{i,j}(k+1,:)<Dtest{i,j}(k,:)
				if Dtest{i,j}(k+1,:) < Dtest{i,j}(k,:)
					TrocasePalpites{i,j}(1,1)=TrocasePalpites{i,j}(1,1)+1;
					if TrocasePalpites{i,j}(1,6)>0
						TrocasePalpites{i,j}(1,3)=TrocasePalpites{i,j}(1,3)+1;
						TrocasePalpites{i,j}(1,5)=TrocasePalpites{i,j}(1,6)*Dtest{i,j}(k,:);
						TrocasePalpites{i,j}(1,6)=0;
					end
				else
					TrocasePalpites{i,j}(1,2)=TrocasePalpites{i,j}(1,2)+1;
					if TrocasePalpites{i,j}(1,6)>0
						TrocasePalpites{i,j}(1,4)=TrocasePalpites{i,j}(1,4)+1;
						TrocasePalpites{i,j}(1,5)=TrocasePalpites{i,j}(1,6)*Dtest{i,j}(k,:);
						TrocasePalpites{i,j}(1,6)=0;
					end					
				end
			end
		end
		if TrocasePalpites{i,j}(1,5)>0
			TrocasePalpites{i,j}(1,7)=(TrocasePalpites{i,j}(1,5)*100/Valor_Local-100);
		else
			TrocasePalpites{i,j}(1,7)=(TrocasePalpites{i,j}(1,6)*100/(Valor_Local/Dtest{i,j}(1,:))-100);
		end
	end
end
end