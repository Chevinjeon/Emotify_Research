from architecture import Model
import torch



tensor = torch.randn(8, 32, 256)
model = Model(input_size=32, output_size=2)


result = model(tensor)