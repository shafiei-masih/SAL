function dataXY = euclideanDistance(dataX1, dataX2, dataY1, dataY2)
    amplitudeX = dataX2 - dataX1;
    amplitudeY = dataY2 - dataY1;
    dataXY = sqrt(amplitudeX.^2 + amplitudeY.^2);