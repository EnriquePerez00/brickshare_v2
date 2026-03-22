import { Dialog, DialogContent } from "@/components/ui/dialog";
import AuthForm from "./AuthForm";

interface AuthModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  initialMode?: "login" | "signup" | "forgot-password" | "update-password";
}

const AuthModal = ({ open, onOpenChange, initialMode = "login" }: AuthModalProps) => {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[450px] p-8">
        <AuthForm 
          initialMode={initialMode} 
          onSuccess={() => onOpenChange(false)} 
        />
      </DialogContent>
    </Dialog>
  );
};

export default AuthModal;
