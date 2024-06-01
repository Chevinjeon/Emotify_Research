import torch
from torch import nn, utils

model_path = 'classifier.pt'

class Classifier(nn.Module):

    def __init__(self, input_size=8, output_size=5):
        super(Classifier, self).__init__()

        # configs
        self.input_size = input_size
        self.output_size = output_size

        self.lstm_input_dim = 256
        self.lstm_hidden_dim = 128
        self.num_lstm_layers = 2
        self.bidir_lstm = True

        # layer definition
        self.conv_layers = nn.Sequential(
            nn.Conv1d(in_channels=self.input_size, out_channels=64, kernel_size=5, stride=1, padding=1),
            nn.ReLU(inplace=True),
            nn.AvgPool1d(kernel_size=2, stride=2),
            
            nn.Conv1d(in_channels=64, out_channels=128, kernel_size=5, stride=1, padding=1),
            nn.ReLU(inplace=True),
            nn.AvgPool1d(kernel_size=2, stride=2),

            nn.Conv1d(in_channels=128, out_channels=256, kernel_size=5, stride=1, padding=1),
            nn.ReLU(inplace=True),
            nn.AvgPool1d(kernel_size=2, stride=2)
        )

        self.lstm_layer = nn.LSTM(
            input_size = self.lstm_input_dim,
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

        x = x.permute(0, 2, 1)
        x = self.conv_layers(x) 
        x = x.permute(0, 2, 1)

        print(x.shape)
        outputs, _ = self.lstm_layer(x)
        outputs = outputs[:, -1, :]

        outputs = self.linear_layer(outputs)
        outputs = nn.functional.softmax(outputs, dim=1)

        return outputs

    