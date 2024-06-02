import torch
from torch import nn, utils


class ResBlock(nn.Module):

    def __init__(self, input_size=32, output_size=256):
        super(ResBlock, self).__init__()

        self.input_size = input_size
        self.conv_kernel = 5
        self.conv_stride = 2
        self.conv_padding = (self.conv_kernel - 1) // 2

        self.conv_layer_1 = nn.Sequential(
            nn.Conv1d(
                in_channels=self.input_size, out_channels=128, 
                kernel_size=self.conv_kernel, stride=self.conv_stride, padding=self.conv_padding),
            nn.BatchNorm1d(num_features=128)
        )

        self.conv_layer_2 = nn.Sequential(
            nn.Conv1d(
                in_channels=128, out_channels=output_size, 
                kernel_size=self.conv_kernel, stride=self.conv_stride, padding=self.conv_padding),
            nn.BatchNorm1d(num_features=output_size)
        )

        self.downsample = nn.Sequential(
            nn.Conv1d(
                in_channels=self.input_size, out_channels=output_size, 
                kernel_size=1, stride=self.conv_stride * self.conv_stride, padding=0
            ),
            nn.BatchNorm1d(num_features=output_size)
        )

        self.relu = nn.ReLU(inplace=False)


    def forward(self, x):
        
        output = self.conv_layer_1(x)
        output = self.relu(output)
        output = self.conv_layer_2(output)

        identity = self.downsample(x)
        output += identity

        output = self.relu(output)

        return output


class LSTM_Classifier(nn.Module):

    def __init__(self, input_size=256, output_size=2):
        super(LSTM_Classifier, self).__init__()

        self.lstm_input_dim = input_size
        self.lstm_hidden_dim = input_size
        self.num_lstm_layers = 3
        self.bidir_lstm = True

        self.lstm_layer = nn.LSTM(
            input_size=self.lstm_input_dim,
            hidden_size=self.lstm_hidden_dim,
            num_layers=self.num_lstm_layers,
            batch_first=True,
            bidirectional=self.bidir_lstm
        )

        self.lstm_output_dim = self.lstm_hidden_dim * 2 if self.bidir_lstm else self.lstm_hidden_dim

        self.linear_layer = nn.Linear(
            in_features=self.lstm_output_dim,
            out_features=output_size
        )

    def forward(self, x):

        outputs, _ = self.lstm_layer(x)
        outputs = outputs[:, -1, :]

        outputs = self.linear_layer(outputs)
        return outputs
    

class Model(nn.Module):

    def __init__(self, input_size=32, output_size=2):
        super(Model, self).__init__()

        self.residual_blocks = ResBlock(input_size=input_size, output_size=256)

        self.lstm_classifier = LSTM_Classifier(input_size=256, output_size=output_size)

    def forward(self, x):

        output = self.residual_blocks(x)

        output = self.lstm_classifier(output)

        return output
    
