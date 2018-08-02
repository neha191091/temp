#include <tensorflow/c/c_api.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>


TF_Buffer* read_file(const char* file);

void free_buffer(void* data, size_t length) {
        free(data);
}

int main() {
      // Graph definition from unzipped https://storage.googleapis.com/download.tensorflow.org/models/inception5h.zip
      // which is used in the Go, Java and Android examples
      TF_Buffer* graph_def = read_file("models/output_graph.pbtxt");
      TF_Graph* graph = TF_NewGraph();

      

      // Import graph_def into graph
      TF_Status* status = TF_NewStatus();

      TF_ImportGraphDefOptions* opts = TF_NewImportGraphDefOptions();
      TF_GraphImportGraphDef(graph, graph_def, opts, status);
      TF_DeleteImportGraphDefOptions(opts);
      if (TF_GetCode(status) != TF_OK) {
              fprintf(stderr, "ERROR: Unable to import graph %s\n", TF_Message(status));
              return 1;
      }
      fprintf(stdout, "Successfully imported graph\n");

      //TF_DeleteStatus(status);
      TF_DeleteBuffer(graph_def);

      // Run a session
      //status = TF_NewStatus();
      
      printf("Creating a New session.....\n");

      TF_SessionOptions* sess_opts = TF_NewSessionOptions();
      TF_Session* session = TF_NewSession(graph, sess_opts, status);

      printf("Session successfully created\n");

// inputs
      TF_Output tf_inpt_z;
      TF_Tensor* tensor_inpt_z;

      tf_inpt_z.oper = TF_GraphOperationByName(graph, "in");
      tf_inpt_z.index = 0;

      const int64_t inpt_z_dims[2] = {3, 2};

      tensor_inpt_z = TF_AllocateTensor(TF_FLOAT, inpt_z_dims, 2, sizeof(float)*6);


      // outputs
      TF_Output tf_out_z;
      TF_Tensor * tensor_out_z;

      tf_out_z.oper = TF_GraphOperationByName(graph, "out");
      tf_out_z.index = 0;

      const int64_t outp_z_dims[2] = {3, 2};

      tensor_out_z = TF_AllocateTensor(TF_FLOAT, outp_z_dims, 2, sizeof(float)*6);


      float inpt_z[3][2] = {{2,2},{0,0},{1,1}};

      printf("Attempting to copy input to tensor data structure....\n");

      memcpy(TF_TensorData(tensor_inpt_z), &inpt_z, sizeof(float)*inpt_z_dims[0]*inpt_z_dims[1]);

      std::cout << "Input data info: " << TF_Dim(tensor_inpt_z, 1) << "\n";
      printf("Successfully copied input to tensor data structure\n");

      TF_Output tf_in[] = {tf_inpt_z};
      TF_Output tf_out[] = {tf_out_z};

      TF_Tensor* intensor[] = {tensor_inpt_z};
      TF_Tensor* tensor_out[] = {tensor_out_z};
      

      printf("Attempting to run the graph\n");

      TF_SessionRun(session, nullptr,
                  &tf_in[0], &intensor[0], 1,
                  &tf_out[0], &tensor_out[0], 1,
                  nullptr, 0, nullptr, status);

      printf("Successfully ran the graph\n");


      float out_z[6];

      

      printf("Attempting to copy output from tensor data structure....\n");
      
      memcpy((char*)out_z, (char *)TF_TensorData(tensor_out[0]), sizeof(float)*outp_z_dims[0]*outp_z_dims[1]);

      printf("Successfully copied output from tensor data structure. Output from graph %.2f\n",out_z[3]);

      TF_DeleteStatus(status);



      TF_DeleteGraph(graph);
      return 0;
}

TF_Buffer* read_file(const char* file) {
      FILE *f = fopen(file, "rb");
      fseek(f, 0, SEEK_END);
      long fsize = ftell(f);
      fseek(f, 0, SEEK_SET);  //same as rewind(f);

      void* data = malloc(fsize);
      fread(data, fsize, 1, f);
      fclose(f);

      TF_Buffer* buf = TF_NewBuffer();
      buf->data = data;
      buf->length = fsize;
      buf->data_deallocator = free_buffer;
      return buf;
}
