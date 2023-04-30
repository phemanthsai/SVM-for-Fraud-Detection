namespace NearestNeighBorsAlgorithm {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;

    @EntryPoint()
    operation init() : Unit {
        let queryArray = [1.0, 2.0, 3.0, 4.0];
        let vectorArray = [[1.5, 2.5, 3.5, 4.5],
                            [2.6, 7.9, 3.4, 10.5],
                            [1.5, 2.5, 3.5, 20.5],
                            [1.3, 2.7, 5.5, 1.5]];
        let distanceThreshold = 1.0;

        let value = nearestNeighborAlgorithm(vectorArray,queryArray,distanceThreshold);
        
        Message("----Distance based classification algorithm in q#-----");
        Message($"Closest = [{value[0]},{value[1]},{value[2]},{value[3]}]");
    }

    function euclideanDistance(x:Double[],y:Double[]):Double{
        let length = Length(x);
        mutable sum = 0.0;
        
        for i in 0 .. length-1 
        {
            let value = x[i]-y[i];
            let output = value*value;
            set sum = sum + output;
        }
        return Sqrt(sum);
    }

    operation nearestNeighborAlgorithm(vectorArray:Double[][],queryArray:Double[],distanceThreshold:Double):Double[]{
        let vectorArrayLength = Length(vectorArray);
        use qubits = Qubit[vectorArrayLength];

        //Apply all qubits to Hadamand gate
        ApplyToEach(H,qubits);

        //Create a state by applying an oracle
        oracle(vectorArray,queryArray,distanceThreshold,qubits);

        let l = (3.142/ 4.0) * Sqrt(IntAsDouble(vectorArrayLength));
        let alliterations = Floor(l);

        for i in 1 .. alliterations
        {
            ApplyToEach(H,qubits);
            ApplyToEach(X,qubits);

            oracle(vectorArray,queryArray,distanceThreshold,qubits);
            
        }

        // Measure the qubits
        let measurement = MultiM(qubits);
        mutable closestIndex = ResultArrayAsInt(measurement);

        if(closestIndex > Length(vectorArray)-1){
           set closestIndex = Length(vectorArray)-1;
        }
        if(closestIndex < 0){
           set closestIndex = 0;
        }

        let nearestVector = vectorArray[closestIndex];
        return nearestVector;
    }

    
    operation oracle(vectors : Double[][], query : Double[], distanceThreshold : Double, register : Qubit[]) : Unit {
        let qubitsCount = Length(vectors);
        for i in 0 .. Length(vectors) - 1 {
            let vector = vectors[i];
            let dist = euclideanDistance(vector, query);
            if (dist <= distanceThreshold) {
                Controlled X([register[i]], register[qubitsCount - 1]);
            }
        }
    }


}
