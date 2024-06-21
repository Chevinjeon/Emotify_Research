import torch
from torch import nn, utils



class LSTM_Classifier(nn.Module):

    def __init__(self, input_size=32, output_size=2):
        super(LSTM_Classifier, self).__init__()

        self.lstm_input_dim = input_size
        self.lstm_hidden_dim = input_size
        self.num_lstm_layers = 1
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
        
        x = x.permute(0,2,1)
        outputs, _ = self.lstm_layer(x)
        outputs = outputs[:, -1, :]

        outputs = self.linear_layer(outputs)
        return outputs
    

class ModelV1(nn.Module):

    def __init__(self, input_size=32, output_size=2):
        super(ModelV1, self).__init__()

        self.lstm_classifier = LSTM_Classifier(input_size=256, output_size=output_size)

    def forward(self, x):

        output = self.lstm_classifier(x)

        output = nn.functional.softmax(output, dim=1)


        return output
    
